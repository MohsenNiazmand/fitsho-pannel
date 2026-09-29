class QuotaItem {
  const QuotaItem({
    this.used = 0,
    this.max = 3,
    this.remaining = 3,
    this.swapsUsed = 0,
    this.swapsMax = 5,
    this.swapsRemaining = 5,
    this.lastGeneratedAt,
    this.lastSwappedAt,
  });

  final int used;
  final int max;
  final int remaining;
  final int swapsUsed;
  final int swapsMax;
  final int swapsRemaining;
  final String? lastGeneratedAt;
  final String? lastSwappedAt;
}

class UserQuotas {
  const UserQuotas({
    required this.diet,
    required this.workout,
  });

  final QuotaItem diet;
  final QuotaItem workout;
}
