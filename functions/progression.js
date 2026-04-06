function readInt(value, fallback = 0) {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }

  const parsed = Number.parseInt(`${value ?? ""}`, 10);
  return Number.isNaN(parsed) ? fallback : parsed;
}

function dateKeyForOffset(offsetMinutes, now = new Date()) {
  const normalizedOffset = readInt(offsetMinutes, 0);
  const shifted = new Date(now.getTime() + normalizedOffset * 60 * 1000);
  const year = shifted.getUTCFullYear();
  const month = `${shifted.getUTCMonth() + 1}`.padStart(2, "0");
  const day = `${shifted.getUTCDate()}`.padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function computeNextDailyStreak(lastDailyLessonDate, todayKey, currentDailyStreak) {
  if (lastDailyLessonDate === todayKey) {
    return currentDailyStreak;
  }

  if (!lastDailyLessonDate) {
    return 1;
  }

  const lastDate = new Date(`${lastDailyLessonDate}T00:00:00.000Z`);
  const currentDate = new Date(`${todayKey}T00:00:00.000Z`);

  if (Number.isNaN(lastDate.getTime()) || Number.isNaN(currentDate.getTime())) {
    return 1;
  }

  const differenceMs = currentDate.getTime() - lastDate.getTime();
  const differenceDays = Math.round(differenceMs / (24 * 60 * 60 * 1000));

  if (differenceDays === 1) {
    return currentDailyStreak + 1;
  }

  if (differenceDays === 0) {
    return currentDailyStreak;
  }

  return 1;
}

module.exports = {
  readInt,
  dateKeyForOffset,
  computeNextDailyStreak,
};
