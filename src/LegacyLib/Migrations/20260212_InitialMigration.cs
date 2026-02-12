namespace LegacyLib.Migrations;

public sealed class _20260212_InitialMigration
{
    // This folder exists to validate workflow exclusions like **/Migrations/**.
    // The code can be intentionally ignored by Sonar in CI.
    public string Up() => "CREATE TABLE Example(Id INT);";
}
