// Minimal Solar Hijri (Jalali) <-> Gregorian conversion for Omarchy shell.
// Conversion logic adapted from the common mjnaderi/Jalali.py algorithm
// (as used in leomoon-studios.omarchy-persian-calendar, MIT).

function pad2(value) {
  var text = String(value)
  return text.length < 2 ? "0" + text : text
}

function toLatinDigits(value) {
  return String(value)
    .replace(/[۰-۹]/g, function(d) { return String("۰۱۲۳۴۵۶۷۸۹".indexOf(d)) })
    .replace(/[٠-٩]/g, function(d) { return String("٠١٢٣٤٥٦٧٨٩".indexOf(d)) })
}

function gregorianToJalali(year, month, day) {
  var d4 = year % 4
  var offsets = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  var gregorianDayOfYear = offsets[month] + day
  if (d4 === 0 && month > 2) gregorianDayOfYear += 1

  var d33 = Math.floor(((year - 16) % 132) * 0.0305)
  var a = (d33 === 3 || d33 < d4 - 1 || d4 === 0) ? 286 : 287
  var b
  if ((d33 === 1 || d33 === 2) && (d33 === d4 || d4 === 1)) b = 78
  else b = (d33 === 3 && d4 === 0) ? 80 : 79
  if (Math.trunc((year - 10) / 63) === 30) { a -= 1; b += 1 }

  var jy, jalaliDayOfYear
  if (gregorianDayOfYear > b) {
    jy = year - 621
    jalaliDayOfYear = gregorianDayOfYear - b
  } else {
    jy = year - 622
    jalaliDayOfYear = gregorianDayOfYear + a
  }

  var jm, jd
  if (jalaliDayOfYear < 187) {
    jm = Math.floor((jalaliDayOfYear - 1) / 31) + 1
    jd = jalaliDayOfYear - 31 * (jm - 1)
  } else {
    jm = Math.floor((jalaliDayOfYear - 187) / 30) + 7
    jd = jalaliDayOfYear - 186 - 30 * (jm - 7)
  }
  return { year: jy, month: jm, day: jd }
}

function jalaliToGregorian(year, month, day) {
  var d4 = (year + 1) % 4
  var jalaliDayOfYear = month < 7
    ? (month - 1) * 31 + day
    : (month - 7) * 30 + day + 186
  var d33 = Math.floor(((year - 55) % 132) * 0.0305)
  var a = (d33 !== 3 && d4 <= d33) ? 287 : 286
  var b
  if ((d33 === 1 || d33 === 2) && (d33 === d4 || d4 === 1)) b = 78
  else b = (d33 === 3 && d4 === 0) ? 80 : 79
  if (Math.trunc((year - 19) / 63) === 20) { a -= 1; b += 1 }

  var gy, gregorianDayOfYear
  if (jalaliDayOfYear <= a) {
    gy = year + 621
    gregorianDayOfYear = jalaliDayOfYear + b
  } else {
    gy = year + 622
    gregorianDayOfYear = jalaliDayOfYear - a
  }

  var lengths = [0, 31, gy % 4 === 0 ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  var gm = 1
  while (gm <= 12 && gregorianDayOfYear > lengths[gm]) {
    gregorianDayOfYear -= lengths[gm]
    gm += 1
  }
  return { year: gy, month: gm, day: gregorianDayOfYear }
}

function persianDaysInYear(year) {
  var start = jalaliToGregorian(Number(year), 1, 1)
  var next = jalaliToGregorian(Number(year) + 1, 1, 1)
  return Math.round((Date.UTC(next.year, next.month - 1, next.day) - Date.UTC(start.year, start.month - 1, start.day)) / 86400000)
}

function persianMonthLength(year, month) {
  var m = Number(month)
  if (m >= 1 && m <= 6) return 31
  if (m >= 7 && m <= 11) return 30
  if (m === 12) return persianDaysInYear(Number(year)) === 366 ? 30 : 29
  return 0
}

function validPersianDate(year, month, day) {
  var y = Number(year), m = Number(month), d = Number(day)
  return Number.isInteger(y) && Number.isInteger(m) && Number.isInteger(d)
    && y >= 1 && y <= 3000 && d >= 1 && d <= persianMonthLength(y, m)
}

function validGregorianDate(year, month, day) {
  var y = Number(year), m = Number(month), d = Number(day)
  if (!Number.isInteger(y) || !Number.isInteger(m) || !Number.isInteger(d)
      || y < 100 || y > 9999 || m < 1 || m > 12 || d < 1 || d > 31) return false
  var date = new Date(Date.UTC(y, m - 1, d))
  return date.getUTCFullYear() === y && date.getUTCMonth() === m - 1 && date.getUTCDate() === d
}

function parseIntField(text) {
  var normalized = toLatinDigits(text).replace(/^\s+|\s+$/g, "")
  return /^\d+$/.test(normalized) ? Number(normalized) : NaN
}

function formatResult(result) {
  return result.year + "/" + pad2(result.month) + "/" + pad2(result.day)
}

function convert(yearText, monthText, dayText, fromPersian) {
  var year = parseIntField(yearText)
  var month = parseIntField(monthText)
  var day = parseIntField(dayText)
  var valid = fromPersian ? validPersianDate(year, month, day) : validGregorianDate(year, month, day)
  if (!valid) return { ok: false, error: "invalid", result: null, text: "" }
  var result = fromPersian ? jalaliToGregorian(year, month, day) : gregorianToJalali(year, month, day)
  return { ok: true, error: "", result: result, text: formatResult(result) }
}

function directionLabel(fromPersian) {
  return fromPersian ? "Jalali → Gregorian" : "Gregorian → Jalali"
}
