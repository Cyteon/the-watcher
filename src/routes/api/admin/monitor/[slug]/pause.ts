import sqlite3 from "sqlite3";
import { open } from "sqlite";

export async function POST({ request, params }) {
  const auth = request.headers.get("Authorization");
  if (!auth) {
    return new Response("Unauthorized", { status: 401 });
  }

  const token = auth.split(" ")[1];

  const db = await open({
    filename: "database.db",
    driver: sqlite3.Database,
  });

  const session = await db.get("SELECT * FROM Sessions WHERE token = ?", [
    token,
  ]);

  if (!session) {
    return new Response("Unauthorized", { status: 401 });
  }

  const user = await db.get("SELECT * FROM Users WHERE id = ?", [
    session.user_id,
  ]);

  if (!user) {
    return new Response("Unauthorized", { status: 401 });
  }

  const slug = params.slug;

  await db.run("UPDATE Monitors SET paused = NOT paused WHERE id = ?", [
    parseInt(slug),
  ]);

  return new Response("Monitor paused status toggled", { status: 200 });
}
