# Pre/Post-Migration Validation Suite
# Ensures data parity between Legacy SQL and Snowflake.

class MigrationValidator:
    def __init__(self, legacy_cursor, snowflake_cursor):
        self.legacy = legacy_cursor
        self.snowflake = snowflake_cursor

    def validate_row_counts(self, table_mapping):
        """Compare total rows between source and target."""
        print("--- Running Row Count Validation ---")
        results = []
        
        for legacy_table, sf_table in table_mapping.items():
            # Query Legacy
            self.legacy.execute(f"SELECT COUNT(*) FROM {legacy_table}")
            l_count = self.legacy.fetchone()[0]

            # Query Snowflake
            self.snowflake.execute(f"SELECT COUNT(*) FROM {sf_table}")
            s_count = self.snowflake.fetchone()[0]

            match = l_count == s_count
            status = "✅ PASS" if match else "❌ FAIL"
            
            print(f"{legacy_table} -> {sf_table}: {status} ({l_count} vs {s_count})")
            results.append({"table": legacy_table, "match": match})
            
        return results

    def validate_checksums(self, table_name, column_name):
        """
        Performs a deep integrity check by comparing a hash of the data.
        """
        print(f"--- Running Checksum Validation: {table_name} ---")
        
        # Legacy Checksum (Example for Postgres/SQL Server)
        self.legacy.execute(f"SELECT SUM(CAST(HASHTEXT(CAST({column_name} AS VARCHAR)) AS BIGINT)) FROM {table_name}")
        legacy_hash = self.legacy.fetchone()[0]

        # Snowflake Checksum
        self.snowflake.execute(f"SELECT HASH_AGG({column_name}) FROM {table_name}")
        sf_hash = self.snowflake.fetchone()[0]

        if legacy_hash == sf_hash:
            print(f"Result: ✅ Data Integrity Verified for {column_name}")
            return True
        else:
            print(f"Result: ❌ Integrity Mismatch detected in {column_name}")
            return False

if __name__ == "__main__":
    # Example usage in a pipeline
    tables = {"users": "legacy_users_raw", "orders": "legacy_orders_raw"}
    # validator = MigrationValidator(l_cur, s_cur)
    # validator.validate_row_counts(tables)
