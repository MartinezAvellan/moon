import os
import json
import sys
from pathlib import Path

import redis
from dotenv import load_dotenv

def main():
    here = Path(__file__).resolve().parent
    moon_root = here.parent

    env_path = moon_root / ".env"
    if not load_dotenv(env_path):
        print(f"⚠️  .env not found at {env_path}", file=sys.stderr)

    host = os.getenv("REDIS_HOST", "localhost")
    port = int(os.getenv("REDIS_PORT", "6379"))
    password = os.getenv("REDIS_PASSWORD", "moon")
    db = int(os.getenv("REDIS_DB", "0"))

    r = redis.Redis(
        host=host,
        port=port,
        password=password,
        db=db,
    )

    r.ping()

    lua_path = moon_root / "script" / "operations.lua"
    with open(lua_path, "r", encoding="utf-8") as f:
        lua_src = f.read()

    script = r.register_script(lua_src)

    keys = ["key:{123}", "60"]
    args = ["100.50", "ADD"]

    res = script(keys=keys, args=args)
    print("Script result:", res)

    val = r.get("key:{123}")
    print("Redis raw value:", val)

    try:
        parsed = json.loads(val) if val is not None else None
        print("Redis parsed value:", parsed)
    except json.JSONDecodeError as e:
        print("JSON decode error:", e, file=sys.stderr)


if __name__ == "__main__":
    main()