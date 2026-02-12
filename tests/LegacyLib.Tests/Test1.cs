namespace LegacyLib.Tests;

[TestClass]
public sealed class PaymentMathTests
{
    [TestMethod]
    public void AddFee_AddsPercent()
    {
        Assert.AreEqual(102.5m, LegacyLib.PaymentMath.AddFee(100m, 2.5m));
    }

    [TestMethod]
    public void AddFee_RejectsNegativeAmount()
    {
        try
        {
            _ = LegacyLib.PaymentMath.AddFee(-1m, 1m);
            Assert.Fail("Expected ArgumentOutOfRangeException.");
        }
        catch (System.ArgumentOutOfRangeException)
        {
            Assert.IsTrue(true);
        }
    }
}
