.PHONY: run
run:
	v run .

.PHONY: fmt
fmt:
	v fmt -w .

.PHONY: migration-dry-run
migration-dry-run:
	go tool sqlite3def main.db --dry-run -f schema.sql

.PHONY: migration
migration:
	go tool sqlite3def main.db -f schema.sql
