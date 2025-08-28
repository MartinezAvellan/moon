package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()

	err := godotenv.Load("../.env")
	if err != nil {
		log.Fatalf("error loading .env file: %v", err)
	}

	addr := os.Getenv("REDIS_HOST") + ":" + os.Getenv("REDIS_PORT")
	pass := os.Getenv("REDIS_PASSWORD")
	dbStr := os.Getenv("REDIS_DB")
	db, _ := strconv.Atoi(dbStr)

	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: pass,
		DB:       db,
	})

	scriptBytes, err := os.ReadFile("../script/operations.lua")
	script := redis.NewScript(string(scriptBytes))

	res, err := script.Run(ctx, rdb, []string{"key:{123}", "60"}, []any{"100.50", "ADD"}).Result()
	if err != nil {
		log.Fatalf("eval: %v", err)
	}

	fmt.Println("Script result:", res)

	val, err := rdb.Get(ctx, "key:{123}").Result()
	if err != nil {
		log.Fatalf("get: %v", err)
	}

	var value string
	if err := json.Unmarshal([]byte(val), &value); err != nil {
		log.Fatalf("unmarshal: %v", err)
	}

	fmt.Println("Redis value:", value)
}
