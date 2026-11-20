using Microsoft.Data.Sqlite;

namespace PamBackend;

public record LiveInput(int? WaitingCarsCount, int? BayCount,
    int[]? OccupiedBays, int[]? OccupiedParkingSpots);

public static class LiveStates
{
    private static int[] Parse(string csv) =>
        csv.Split(',', StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();

    private static string Csv(IEnumerable<int> values) => string.Join(',', values.Distinct().Order());

    private static object? Find(SqliteConnection conn, long washId)
    {
        using var cmd = conn.Cmd(
            "SELECT l.waiting_cars, l.bay_count, l.occupied_bays, l.occupied_parking, l.updated_at " +
            "FROM wash_live l WHERE l.wash_id = $id",
            ("$id", washId));
        using var r = cmd.ExecuteReader();
        if (!r.Read()) return null;

        var occupied = Parse(r.GetString(2)).ToHashSet();
        return new
        {
            washId = washId.ToString(),
            timestamp = r.GetString(4),
            waitingCarsCount = r.GetInt32(0),
            occupiedParkingSpots = Parse(r.GetString(3)),
            bays = Enumerable.Range(1, r.GetInt32(1))
                .Select(n => new { id = n, occupied = occupied.Contains(n), vehicleId = (string?)null }),
        };
    }

    /// <summary>GET /carwashes/{id}/live -> 200 | 404</summary>
    public static IResult Get(HttpContext context, long id)
    {
        using var conn = Db.Open();
        var live = Find(conn, id);
        return live is null ? Errors.NotFound("Live state not found") : Results.Json(live);
    }

    /// <summary>PUT /carwashes/{id}/live -> 200 | 400 | 404 (upsert)</summary>
    public static IResult Put(HttpContext context, long id, LiveInput input)
    {
        var userId = Auth.CurrentUserId(context);
        using var conn = Db.Open();
        if (CarWashes.CheckOwner(conn, userId, id) is { } denied) return denied;

        var waiting = input.WaitingCarsCount;
        if (waiting is null or < 0 or > 10)
            return Errors.Validation("waitingCarsCount must be 0..10");
        var bayCount = input.BayCount ?? 11;
        if (bayCount is < 1 or > 20) return Errors.Validation("bayCount must be 1..20");
        var bays = input.OccupiedBays ?? [];
        if (bays.Any(b => b < 1 || b > bayCount))
            return Errors.Validation("occupiedBays must be in 1..bayCount");
        var parking = input.OccupiedParkingSpots ?? [];
        if (parking.Any(p => p < 1)) return Errors.Validation("occupiedParkingSpots must be >= 1");

        using (var upsert = conn.Cmd(
                   "INSERT INTO wash_live (wash_id, waiting_cars, bay_count, occupied_bays, " +
                   "occupied_parking, updated_at) VALUES ($id, $w, $n, $b, $p, $t) " +
                   "ON CONFLICT (wash_id) DO UPDATE SET waiting_cars = $w, bay_count = $n, " +
                   "occupied_bays = $b, occupied_parking = $p, updated_at = $t",
                   ("$id", id), ("$w", waiting), ("$n", bayCount),
                   ("$b", Csv(bays)), ("$p", Csv(parking)), ("$t", Db.NowIso())))
        {
            upsert.ExecuteNonQuery();
        }
        return Results.Json(Find(conn, id)!);
    }

    /// <summary>DELETE /carwashes/{id}/live -> 204 | 404</summary>
    public static IResult Delete(HttpContext context, long id)
    {
        using var conn = Db.Open();
        if (CarWashes.CheckOwner(conn, Auth.CurrentUserId(context), id) is { } denied)
            return denied;
        if (Find(conn, id) is null) return Errors.NotFound("Live state not found");

        using var delete = conn.Cmd("DELETE FROM wash_live WHERE wash_id = $id", ("$id", id));
        delete.ExecuteNonQuery();
        return Results.NoContent();
    }
}
