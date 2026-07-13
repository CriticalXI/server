-----------------------------------
-- Disable Optional Storage
-- Defaults new players to zerod out wardrobe and case storage
-----------------------------------
ALTER TABLE `char_storage` ALTER COLUMN `case`      SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe`  SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe2` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe3` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe4` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe5` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe6` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe7` SET DEFAULT 0;
ALTER TABLE `char_storage` ALTER COLUMN `wardrobe8` SET DEFAULT 0;
