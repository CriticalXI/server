-----------------------------------
-- Module: Adjust city bazaar taxes to ToAU rates
-- Source for Jeuno tax removal: https://www.bg-wiki.com/ffxi/Version_Update_(12/08/2008)
-- Source for Remaining zone tax removal: https://forum.square-enix.com/ffxi/threads/40059
-----------------------------------

UPDATE `zone_settings` SET `tax` = 10.00 WHERE `name` = 'Al_Zahbi';
UPDATE `zone_settings` SET `tax` = 10.00 WHERE `name` = 'Aht_Urhgan_Whitegate';
UPDATE `zone_settings` SET `tax` = 10.00 WHERE `name` = 'Chocobo_Circuit';
UPDATE `zone_settings` SET `tax` = 10.00 WHERE `name` = 'The_Colosseum';
UPDATE `zone_settings` SET `tax` = 5.00  WHERE `name` = 'RuLude_Gardens';
UPDATE `zone_settings` SET `tax` = 5.00  WHERE `name` = 'Upper_Jeuno';
UPDATE `zone_settings` SET `tax` = 5.00  WHERE `name` = 'Lower_Jeuno';
UPDATE `zone_settings` SET `tax` = 5.00  WHERE `name` = 'Port_Jeuno';
