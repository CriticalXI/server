-----------------------------------
-- Default Spell List Adjustments
-- Removes many spells that are only present for level 99 content
-- Any monsters that use the removed spells should be given unique spell lists instead
-----------------------------------

-----------------------------------
-- Beastmen RDM (3)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 74  WHERE `spell_list_id` = 3 AND `spell_id` = 24;  -- dia_ii (31~59 -> 31~74)
UPDATE `mob_spell_lists` SET `min_level` = 75  WHERE `spell_list_id` = 3 AND `spell_id` = 25;  -- dia_iii (60~255 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 34;  -- diaga_ii (55~70 -> 55~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 46;  -- protect_iv (63~76 -> 63~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 51;  -- shell_iv (68~86 -> 68~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 108; -- regen (21~75 -> 21~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 146; -- fire_iii (71~85 -> 71~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 151; -- blizzard_iii (73~88 -> 73~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 156; -- aero_iii (69~82 -> 69~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 161; -- stone_iii (65~76 -> 65~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 166; -- thunder_iii (75~91 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 3 AND `spell_id` = 171; -- water_iii (67~88 -> 67~255)
UPDATE `mob_spell_lists` SET `max_level` = 74  WHERE `spell_list_id` = 3 AND `spell_id` = 231; -- bio_ii (36~70 -> 36~74)
UPDATE `mob_spell_lists` SET `min_level` = 75  WHERE `spell_list_id` = 3 AND `spell_id` = 232; -- bio_iii (71~255 -> 75~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 35;  -- diaga_iii (71~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 47;  -- protect_v (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 52;  -- shell_v (87~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 110; -- regen_ii (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 147; -- fire_iv (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 152; -- blizzard_iv (89~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 157; -- aero_iv (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 162; -- stone_iv (77~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 167; -- thunder_iv (89~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 3 AND `spell_id` = 172; -- water_iv (80~255)

-----------------------------------
-- Beastmen PLD (4)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 4 AND `spell_id` = 46; -- protect_iv (70~89 -> 70~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 4 AND `spell_id` = 50; -- shell_iii (60~79 -> 60~99)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 4 AND `spell_id` = 47; -- protect_v (90~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 4 AND `spell_id` = 51; -- shell_iv (80~255)

-----------------------------------
-- Beastmen DRK (5)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 145; -- fire_ii (60~71 -> 60~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 150; -- blizzard_ii (66~78 -> 66~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 155; -- aero_ii (54~65 -> 54~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 160; -- stone_ii (42~53 -> 42~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 165; -- thunder_ii (72~83 -> 72~99)
UPDATE `mob_spell_lists` SET `max_level` = 99 WHERE `spell_list_id` = 5 AND `spell_id` = 170; -- water_ii (48~59 -> 48~99)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 146; -- fire_iii (88~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 151; -- blizzard_iii (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 156; -- aero_iii (84~91)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 161; -- stone_iii (76~83)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 166; -- thunder_iii (96~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 5 AND `spell_id` = 171; -- water_iii (80~87)

-----------------------------------
-- Beastmen BRD (6)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 6 AND `spell_id` = 373; -- foe_requiem_vi (67~75 -> 67~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 6 AND `spell_id` = 376; -- horde_lullaby (27~91 -> 27~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 6 AND `spell_id` = 382; -- armys_paeon_v (65~77 -> 65~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 6 AND `spell_id` = 374; -- foe_requiem_vii (76~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 6 AND `spell_id` = 377; -- horde_lullaby_ii (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 6 AND `spell_id` = 383; -- armys_paeon_vi (78~255)

-----------------------------------
-- Beastmen NIN (7)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 321; -- katon_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 324; -- hyoton_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 327; -- huton_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 330; -- doton_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 333; -- raiton_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 336; -- suiton_ni (40~72 -> 40~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 339; -- utsusemi_ni (37~72 -> 37~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 345; -- hojo_ni (48~75 -> 48~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 7 AND `spell_id` = 351; -- dokumori_ni (56~74 -> 56~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 322; -- katon_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 325; -- hyoton_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 328; -- huton_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 331; -- doton_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 334; -- raiton_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 337; -- suiton_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 340; -- utsusemi_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 346; -- hojo_san (76~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 349; -- kurayami_san (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 7 AND `spell_id` = 352; -- dokumori_san (76~255)

-----------------------------------
-- Worm (9)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 9 AND `spell_id` = 162; -- stone_iv (68~76 -> 68~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 9 AND `spell_id` = 163; -- stone_v (77~255)

-----------------------------------
-- Hecteyes (10)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 10 AND `spell_id` = 147; -- fire_iv (76~85 -> 76~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 10 AND `spell_id` = 157; -- aero_iv (72~82 -> 72~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 10 AND `spell_id` = 167; -- thunder_iv (75~91 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 10 AND `spell_id` = 172; -- water_iv (70~79 -> 70~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 10 AND `spell_id` = 148; -- fire_v (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 10 AND `spell_id` = 158; -- aero_v (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 10 AND `spell_id` = 168; -- thunder_v (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 10 AND `spell_id` = 173; -- water_v (80~255)

-----------------------------------
-- Ahriman (11)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 11 AND `spell_id` = 147; -- fire_iv (73~85 -> 73~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 11 AND `spell_id` = 157; -- aero_iv (72~82 -> 72~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 11 AND `spell_id` = 167; -- thunder_iv (75~91 -> 75~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 11 AND `spell_id` = 148; -- fire_v (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 11 AND `spell_id` = 158; -- aero_v (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 11 AND `spell_id` = 168; -- thunder_v (92~255)

-----------------------------------
-- Beastmen WHM (20)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 5;  -- cure_v (61~79 -> 61~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 21; -- holy (50~94 -> 50~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 24; -- dia_ii (36~64 -> 36~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 30; -- banish_iii (61~72 -> 61~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 34; -- diaga_ii (60~73 -> 60~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 46; -- protect_iv (63~75 -> 63~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 20 AND `spell_id` = 51; -- shell_iv (68~75 -> 68~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 6;   -- cure_vi (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 22;  -- holy_ii (95~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 25;  -- dia_iii (65~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 31;  -- banish_iv (73~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 35;  -- diaga_iii (74~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 47;  -- protect_v (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 52;  -- shell_v (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 20 AND `spell_id` = 477; -- regen_iv (86~255)

-----------------------------------
-- Beastmen BLM (21)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 147; -- fire_iv (73~85 -> 73~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 152; -- blizzard_iv (74~88 -> 74~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 157; -- aero_iv (72~82 -> 72~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 162; -- stone_iv (68~73 -> 68~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 167; -- thunder_iv (75~92 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 172; -- water_iv (70~78 -> 70~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 21 AND `spell_id` = 247; -- aspir (25~82 -> 25~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 148; -- fire_v (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 153; -- blizzard_v (89~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 158; -- aero_v (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 163; -- stone_v (77~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 168; -- thunder_v (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 173; -- water_v (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 21 AND `spell_id` = 248; -- aspir_ii (83~255)

-----------------------------------
-- Undead (28)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 147; -- fire_iv (73~85 -> 73~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 152; -- blizzard_iv (74~88 -> 74~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 157; -- aero_iv (72~82 -> 72~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 162; -- stone_iv (68~72 -> 68~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 167; -- thunder_iv (75~92 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 28 AND `spell_id` = 172; -- water_iv (70~79 -> 70~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 148; -- fire_v (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 153; -- blizzard_v (89~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 158; -- aero_v (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 163; -- stone_v (77~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 168; -- thunder_v (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 28 AND `spell_id` = 173; -- water_v (80~255)

-----------------------------------
-- MagicPot (36)
-----------------------------------
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 147; -- fire_iv (73~85 -> 73~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 152; -- blizzard_iv (74~88 -> 74~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 157; -- aero_iv (72~82 -> 72~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 162; -- stone_iv (68~73 -> 68~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 167; -- thunder_iv (75~92 -> 75~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 172; -- water_iv (70~78 -> 70~255)
UPDATE `mob_spell_lists` SET `max_level` = 255 WHERE `spell_list_id` = 36 AND `spell_id` = 247; -- aspir (25~82 -> 25~255)

DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 148; -- fire_v (86~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 153; -- blizzard_v (89~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 158; -- aero_v (83~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 163; -- stone_v (77~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 168; -- thunder_v (92~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 173; -- water_v (80~255)
DELETE FROM `mob_spell_lists` WHERE `spell_list_id` = 36 AND `spell_id` = 248; -- aspir_ii (83~255)
