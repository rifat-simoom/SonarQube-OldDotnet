namespace LegacyLib;

public static class PaymentMath
{
    public static decimal AddFee(decimal amount, decimal feePercent)
    {
        if (amount < 0)
        {
            throw new System.ArgumentOutOfRangeException(nameof(amount));
        }

        if (feePercent < 0)
        {
            throw new System.ArgumentOutOfRangeException(nameof(feePercent));
        }

        return amount + (amount * feePercent / 100m);
    }
}
