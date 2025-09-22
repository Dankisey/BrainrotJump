local StarterPackConfig = {}

StarterPackConfig.Rewards = {
	Potions = {
        JumpPowerPotion = 1;
        CashPotion = 1;
        WinsPotion = 1;
    };
    Cash = {
		Amount = 100000;
        TransactionType = Enum.AnalyticsEconomyTransactionType.IAP;
        Sku = "StarterPack";
    };
}

return StarterPackConfig