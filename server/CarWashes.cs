using Microsoft.Data.Sqlite;

namespace PamBackend;

public record CarWash(long Id, string Name, string Area, string City, string? LogoAsset, string CreatedAt);
public record CarWashInput(string? Name, string? Area, string? City, string? LogoAsset);

public static class CarWashes
{
    private const string Columns = "id, name, area, city, logo_asset, created_at";

    private static CarWash Read(SqliteDataReader r) => new(
        r.GetInt64(0), r.GetString(1), r.GetString(2), r.GetString(3),
        r.IsDBNull(4) ? null : r.GetString(4), r.GetString(5));

    public static CarWash? Find(SqliteConnection conn, long id)
    {
        using var cmd = conn.Cmd($"SELECT {Columns} FROM carwashes WHERE id = $id", ("$id", id));
        using var reader = cmd.ExecuteReader();
        return reader.Read() ? Read(reader) : null;
    }

    public static IResult? CheckOwner(SqliteConnection conn, long userId, long id)
    {
        using var cmd = conn.Cmd("SELECT user_id FROM carwashes WHERE id = $id", ("$id", id));
        var owner = cmd.ExecuteScalar();
        if (owner is null) return Errors.NotFound("Car wash not found");
        if ((long)owner != userId) return Errors.Forbidden("Only the owner can change this car wash");
        return null;
    }

    private static (CarWashInput? Clean, IResult? Error) Validate(CarWashInput input)
    {
        var name = Errors.Trimmed(input.Name);
        if (name is null) return (null, Errors.Validation("name is required"));
        var area = Errors.Trimmed(input.Area);
        if (area is null) return (null, Errors.Validation("area is required"));
        var city = Errors.Trimmed(input.City);
        if (city is null) return (null, Errors.Validation("city is required"));
        return (new CarWashInput(name, area, city, Errors.Trimmed(input.LogoAsset)), null);
    }

    public static IResult List(HttpContext context,
        int page = 1, int limit = 20, string search = "")
    {
        page = Math.Max(page, 1);
        limit = Math.Clamp(limit, 1, 100);

        const string where =
            "name LIKE $pattern OR area LIKE $pattern OR city LIKE $pattern";
        var pattern = $"%{search}%";

        using var conn = Db.Open();
        long total;
        using (var count = conn.Cmd($"SELECT COUNT(*) FROM carwashes WHERE {where}",
                   ("$pattern", pattern)))
        {
            total = (long)count.ExecuteScalar()!;
        }

        var items = new List<CarWash>();
        using var cmd = conn.Cmd(
            $"SELECT {Columns} FROM carwashes WHERE {where} " +
            "ORDER BY id ASC LIMIT $limit OFFSET $offset",
            ("$pattern", pattern),
            ("$limit", limit), ("$offset", (page - 1) * limit));
        using var reader = cmd.ExecuteReader();
        while (reader.Read()) items.Add(Read(reader));

        return Results.Json(new { items, page, limit, total });
    }

    public static IResult Create(HttpContext context, CarWashInput input)
    {
        var (clean, error) = Validate(input);
        if (error is not null) return error;
        var userId = Auth.CurrentUserId(context);

        using var conn = Db.Open();
        using (var insert = conn.Cmd(
                   "INSERT INTO carwashes (user_id, name, area, city, logo_asset, created_at) " +
                   "VALUES ($userId, $name, $area, $city, $logo, $createdAt)",
                   ("$userId", userId), ("$name", clean!.Name), ("$area", clean.Area),
                   ("$city", clean.City), ("$logo", clean.LogoAsset), ("$createdAt", Db.NowIso())))
        {
            insert.ExecuteNonQuery();
        }
        var wash = Find(conn, conn.LastInsertRowId())!;
        return Results.Created($"/carwashes/{wash.Id}", wash);
    }

    /// <summary>GET /carwashes/{id} -> 200 | 404</summary>
    public static IResult GetOne(HttpContext context, long id)
    {
        using var conn = Db.Open();
        var wash = Find(conn, id);
        return wash is null ? Errors.NotFound("Car wash not found") : Results.Json(wash);
    }

    /// <summary>PUT /carwashes/{id} -> 200 | 400 | 403 | 404</summary>
    public static IResult Update(HttpContext context, long id, CarWashInput input)
    {
        var userId = Auth.CurrentUserId(context);
        using var conn = Db.Open();
        if (CheckOwner(conn, userId, id) is { } denied) return denied;

        var (clean, error) = Validate(input);
        if (error is not null) return error;

        using (var update = conn.Cmd(
                   "UPDATE carwashes SET name = $name, area = $area, city = $city, " +
                   "logo_asset = $logo WHERE id = $id",
                   ("$name", clean!.Name), ("$area", clean.Area), ("$city", clean.City),
                   ("$logo", clean.LogoAsset), ("$id", id)))
        {
            update.ExecuteNonQuery();
        }
        return Results.Json(Find(conn, id)!);
    }

    public static IResult Delete(HttpContext context, long id)
    {
        using var conn = Db.Open();
        if (CheckOwner(conn, Auth.CurrentUserId(context), id) is { } denied) return denied;

        using (var live = conn.Cmd("DELETE FROM wash_live WHERE wash_id = $id", ("$id", id)))
        {
            live.ExecuteNonQuery();
        }
        using var delete = conn.Cmd("DELETE FROM carwashes WHERE id = $id", ("$id", id));
        delete.ExecuteNonQuery();
        return Results.NoContent();
    }
}
