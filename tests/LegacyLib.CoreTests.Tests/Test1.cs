namespace LegacyLib.CoreTests.Tests;

[TestClass]
public sealed class PaymentMathCoreTests
{
    [TestMethod]
    public void AddFee_ZeroFee_ReturnsSameAmount()
    {
        Assert.AreEqual(100m, LegacyLib.PaymentMath.AddFee(100m, 0m));
    }
}
