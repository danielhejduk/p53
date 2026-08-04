{ lib, ... }:

{
  time.timeZone = "Europe/Prague";

  # English UI, Czech formats for dates, numbers, paper size, etc.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.genAttrs [
    "LC_ADDRESS"
    "LC_IDENTIFICATION"
    "LC_MEASUREMENT"
    "LC_MONETARY"
    "LC_NAME"
    "LC_NUMERIC"
    "LC_PAPER"
    "LC_TELEPHONE"
    "LC_TIME"
  ] (_: "cs_CZ.UTF-8");
}
