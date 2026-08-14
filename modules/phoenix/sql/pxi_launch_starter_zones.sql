-- --------------------------------------------------------
-- Launch month starter zones
-- West/East Ronfaure, North/South Gustaberg, West/East Sarutabaruta
--
-- Field mobs respawn faster:
--    60s -> 0s
--   180s -> 60s
--   300s -> 60s
-- Loot moves one treasure hunter bracket down (15% -> 10%, 10% -> 5%,
-- 5% -> 1%, 1% -> 0.5%). The TH system snaps rates to brackets, so only
-- bracket values work. Four quest items keep their normal rates and are
-- marked below. Steal and despoil pools are unchanged. Shadow droplists
-- live in the 3500-3549 block.
--
-- Each zone gets 150 extra level 1 mobs with no loot (groups 200/201),
-- spread across the zone on existing trash spawn positions, offsets 874-1023.
--
-- NMs, placeholder groups, aggressive mobs, night and weather mobs, and
-- scripted mobs are untouched.
--
-- Temporary. To end the event, delete this file, reimport the database with
-- dbtool, and restart.
-- --------------------------------------------------------

-- Respawn timers.

-- West Ronfaure (Zone 100)
-- was 60s: Wild_Rabbit, Tunnel_Worm
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 100 AND `groupid` IN (6,7);
-- was 180s: Carrion_Worm, River_Crab
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 100 AND `groupid` IN (10,27);
-- was 300s: Forest_Funguar, Wild_Sheep
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 100 AND `groupid` IN (15,18);

-- East Ronfaure (Zone 101)
-- was 60s: Wild_Rabbit, Tunnel_Worm
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 101 AND `groupid` IN (6,7);
-- was 180s: Forest_Hare
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 101 AND `groupid` IN (9);
-- was 300s: Forest_Funguar, Scarab_Beetle, Wild_Sheep
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 101 AND `groupid` IN (11,12,18);

-- North Gustaberg (Zone 106)
-- was 60s: Huge_Hornet, Tunnel_Worm
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 106 AND `groupid` IN (6,7);
-- was 180s: River_Crab, Vulture
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 106 AND `groupid` IN (18,21);
-- was 300s: Stone_Eater, Ornery_Sheep, Rock_Lizard
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 106 AND `groupid` IN (10,11,19);

-- South Gustaberg (Zone 107)
-- was 60s: Huge_Hornet, Tunnel_Worm
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 107 AND `groupid` IN (7,8);
-- was 180s: Maneating_Hornet, Stone_Eater, Walking_Sapling, Vulture, Land_Crab
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 107 AND `groupid` IN (10,11,21,22,30);

-- West Sarutabaruta (Zone 115)
-- was 60s: Tiny_Mandragora, Bumblebee
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 115 AND `groupid` IN (6,7);
-- was 180s: Savanna_Rarab, River_Crab, Giant_Bee
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 115 AND `groupid` IN (8,9,23);
-- was 300s: Crawler, Crawler
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 115 AND `groupid` IN (10,22);

-- East Sarutabaruta (Zone 116)
-- was 60s: Tiny_Mandragora, Bumblebee
UPDATE `mob_groups` SET `respawntime` = 0 WHERE `zoneid` = 116 AND `groupid` IN (6,7);
-- was 180s: Carrion_Crow, River_Crab, Mandragora, Giant_Bee, Pug_Pugil
UPDATE `mob_groups` SET `respawntime` = 60 WHERE `zoneid` = 116 AND `groupid` IN (10,19,20,21,56);

-- Shadow droplists. The DELETE keeps dbtool re-runs from duplicating rows.
DELETE FROM `mob_droplist` WHERE `dropId` BETWEEN 3500 AND 3549;

-- 3500 = 43 one bracket down (Carrion_Crow z116)
INSERT INTO `mob_droplist` VALUES (3500,0,0,1000,847,100);           -- Bird Feather (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3500,0,0,1000,4570,50);           -- Bird Egg (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3500,2,0,1000,847,0);             -- Bird Feather (Steal)
INSERT INTO `mob_droplist` VALUES (3500,4,0,1000,847,0);             -- Bird Feather (Despoil)
INSERT INTO `mob_droplist` VALUES (3500,4,0,1000,4570,0);            -- Bird Egg (Despoil)

-- 3501 = 207 one bracket down (Vulture z106, Vulture z107)
INSERT INTO `mob_droplist` VALUES (3501,0,0,1000,847,100);           -- Bird Feather (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3501,0,0,1000,4570,50);           -- Bird Egg (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3501,2,0,1000,847,0);             -- Bird Feather (Steal)
INSERT INTO `mob_droplist` VALUES (3501,4,0,1000,847,0);             -- Bird Feather (Despoil)
INSERT INTO `mob_droplist` VALUES (3501,4,0,1000,4570,0);            -- Bird Egg (Despoil)

-- 3502 = 367 one bracket down (Wild_Sheep z100, Wild_Sheep z101)
INSERT INTO `mob_droplist` VALUES (3502,0,0,1000,4372,100);          -- Slice Of Giant Sheep Meat (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3502,0,0,1000,882,10);            -- Sheep Tooth (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3502,0,0,1000,505,50);            -- Sheepskin (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3502,2,0,1000,832,0);             -- Clump Of Sheep Wool (Steal)
INSERT INTO `mob_droplist` VALUES (3502,4,0,1000,882,50);            -- Sheep Tooth (Despoil)

-- 3503 = 388 one bracket down (Bumblebee z115, Bumblebee z116)
INSERT INTO `mob_droplist` VALUES (3503,0,0,1000,846,50);            -- Insect Wing (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3503,0,0,1000,4444,50);           -- Rarab Tail (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3503,0,0,1000,4370,10);           -- Pot Of Honey (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3503,2,0,1000,4370,0);            -- Pot Of Honey (Steal)
INSERT INTO `mob_droplist` VALUES (3503,4,0,1000,912,0);             -- Beehive Chip (Despoil)
INSERT INTO `mob_droplist` VALUES (3503,4,0,1000,925,0);             -- Giant Stinger (Despoil)
INSERT INTO `mob_droplist` VALUES (3503,4,0,1000,4370,0);            -- Pot Of Honey (Despoil)

-- 3504 = 428 one bracket down (Carrion_Worm z100, Stone_Eater z106, Stone_Eater z107)
INSERT INTO `mob_droplist` VALUES (3504,0,0,1000,768,100);           -- Flint Stone (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3504,0,0,1000,640,50);            -- Chunk Of Copper Ore (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3504,0,0,1000,642,10);            -- Chunk Of Zinc Ore (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3504,0,0,1000,736,5);             -- Chunk Of Silver Ore (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3504,2,0,1000,17296,0);           -- Pebble (Steal)
INSERT INTO `mob_droplist` VALUES (3504,4,0,1000,640,0);             -- Chunk Of Copper Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3504,4,0,1000,643,0);             -- Chunk Of Iron Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3504,4,0,1000,736,0);             -- Chunk Of Silver Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3504,4,0,1000,642,0);             -- Chunk Of Zinc Ore (Despoil)

-- 3505 = 463 one bracket down (Pug_Pugil z116)
INSERT INTO `mob_droplist` VALUES (3505,0,0,1000,868,50);            -- Handful Of Pugil Scales (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3505,2,0,1000,864,0);             -- Handful Of Fish Scales (Steal)
INSERT INTO `mob_droplist` VALUES (3505,4,0,1000,868,0);             -- Handful Of Pugil Scales (Despoil)
INSERT INTO `mob_droplist` VALUES (3505,4,0,1000,864,0);             -- Handful Of Fish Scales (Despoil)

-- 3506 = 481 one bracket down (River_Crab z106, Land_Crab z107, River_Crab z115)
INSERT INTO `mob_droplist` VALUES (3506,0,0,1000,936,100);           -- Chunk Of Rock Salt (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3506,0,0,1000,4400,5);            -- Slice Of Land Crab Meat (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3506,2,0,1000,936,0);             -- Chunk Of Rock Salt (Steal)
INSERT INTO `mob_droplist` VALUES (3506,4,0,1000,4400,0);            -- Slice Of Land Crab Meat (Despoil)
INSERT INTO `mob_droplist` VALUES (3506,4,0,1000,881,0);             -- Crab Shell (Despoil)

-- 3507 = 530 one bracket down (Crawler z115)
INSERT INTO `mob_droplist` VALUES (3507,0,0,1000,816,50);            -- Spool Of Silk Thread (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3507,0,0,1000,1156,50);           -- Crawler Calculus (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3507,0,0,1000,583,10);            -- Smooth Stone (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3507,4,0,1000,839,0);             -- Piece Of Crawler Cocoon (Despoil)
INSERT INTO `mob_droplist` VALUES (3507,4,0,1000,4357,0);            -- Crawler Egg (Despoil)

-- 3508 = 584 one bracket down (Maneating_Hornet z107, Giant_Bee z115, Giant_Bee z116)
INSERT INTO `mob_droplist` VALUES (3508,0,0,1000,912,100);           -- Beehive Chip (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3508,0,0,1000,4370,50);           -- Pot Of Honey (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3508,0,0,1000,846,10);            -- Insect Wing (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3508,0,0,1000,925,5);             -- Giant Stinger (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3508,2,0,1000,4370,0);            -- Pot Of Honey (Steal)
INSERT INTO `mob_droplist` VALUES (3508,4,0,1000,912,0);             -- Beehive Chip (Despoil)
INSERT INTO `mob_droplist` VALUES (3508,4,0,1000,925,0);             -- Giant Stinger (Despoil)
INSERT INTO `mob_droplist` VALUES (3508,4,0,1000,4370,0);            -- Pot Of Honey (Despoil)

-- 3509 = 892 one bracket down (Forest_Funguar z100, Forest_Funguar z101)
INSERT INTO `mob_droplist` VALUES (3509,0,0,1000,4374,100);          -- Sleepshroom (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3509,2,0,1000,4374,0);            -- Sleepshroom (Steal)
INSERT INTO `mob_droplist` VALUES (3509,4,0,1000,4373,0);            -- Woozyshroom (Despoil)
INSERT INTO `mob_droplist` VALUES (3509,4,0,1000,4374,0);            -- Sleepshroom (Despoil)
INSERT INTO `mob_droplist` VALUES (3509,4,0,1000,4375,0);            -- Danceshroom (Despoil)
INSERT INTO `mob_droplist` VALUES (3509,4,0,1000,5680,0);            -- Agaricus Mushroom (Despoil)

-- 3510 = 893 one bracket down (Wild_Rabbit z101)
INSERT INTO `mob_droplist` VALUES (3510,0,0,1000,856,100);           -- Rabbit Hide (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3510,0,0,1000,856,50);            -- Rabbit Hide (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3510,2,0,1000,4389,0);            -- San Dorian Carrot (Steal)
INSERT INTO `mob_droplist` VALUES (3510,4,0,1000,856,0);             -- Rabbit Hide (Despoil)
INSERT INTO `mob_droplist` VALUES (3510,4,0,1000,4358,0);            -- Slice Of Hare Meat (Despoil)

-- 3511 = 894 one bracket down (Wild_Rabbit z100, Forest_Hare z101)
INSERT INTO `mob_droplist` VALUES (3511,0,0,1000,4358,100);          -- Slice Of Hare Meat (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3511,0,0,1000,856,50);            -- Rabbit Hide (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3511,2,0,1000,4389,0);            -- San Dorian Carrot (Steal)
INSERT INTO `mob_droplist` VALUES (3511,4,0,1000,856,0);             -- Rabbit Hide (Despoil)
INSERT INTO `mob_droplist` VALUES (3511,4,0,1000,4358,0);            -- Slice Of Hare Meat (Despoil)

-- 3512 = 1334 one bracket down (Huge_Hornet z106, Huge_Hornet z107)
INSERT INTO `mob_droplist` VALUES (3512,0,0,1000,846,50);            -- Insect Wing (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3512,0,0,1000,4370,10);           -- Pot Of Honey (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3512,4,0,1000,912,0);             -- Beehive Chip (Despoil)
INSERT INTO `mob_droplist` VALUES (3512,4,0,1000,925,0);             -- Giant Stinger (Despoil)
INSERT INTO `mob_droplist` VALUES (3512,4,0,1000,4370,0);            -- Pot Of Honey (Despoil)

-- 3513 = 1596 one bracket down (Mandragora z116)
INSERT INTO `mob_droplist` VALUES (3513,0,0,1000,17344,50);          -- Cornette (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3513,0,0,1000,4368,100);          -- Two-Leaf Mandragora Bud (quest item, unchanged)
INSERT INTO `mob_droplist` VALUES (3513,0,0,1000,934,10);            -- Pinch Of Yuhtunga Sulfur (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3513,0,0,1000,4369,5);            -- Four-Leaf Mandragora Bud (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3513,2,0,1000,834,0);             -- Ball Of Saruta Cotton (Steal)
INSERT INTO `mob_droplist` VALUES (3513,4,0,1000,4368,0);            -- Two-Leaf Mandragora Bud (Despoil)
INSERT INTO `mob_droplist` VALUES (3513,4,0,1000,834,0);             -- Ball Of Saruta Cotton (Despoil)

-- 3514 = 1958 one bracket down (Ornery_Sheep z106)
INSERT INTO `mob_droplist` VALUES (3514,0,0,1000,4372,100);          -- Slice Of Giant Sheep Meat (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3514,0,0,1000,505,50);            -- Sheepskin (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3514,0,0,1000,1898,5);            -- Vial Of Fresh Blood (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3514,0,0,1000,882,5);             -- Sheep Tooth (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3514,2,0,1000,832,0);             -- Clump Of Sheep Wool (Steal)
INSERT INTO `mob_droplist` VALUES (3514,4,0,1000,882,50);            -- Sheep Tooth (Despoil)

-- 3515 = 2101 one bracket down (River_Crab z100)
INSERT INTO `mob_droplist` VALUES (3515,0,0,1000,936,100);           -- Chunk Of Rock Salt (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3515,0,0,1000,1019,100);          -- Chunk Of Lufet Salt (quest item, unchanged)
INSERT INTO `mob_droplist` VALUES (3515,0,0,1000,4400,5);            -- Slice Of Land Crab Meat (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3515,2,0,1000,936,0);             -- Chunk Of Rock Salt (Steal)
INSERT INTO `mob_droplist` VALUES (3515,4,0,1000,4400,0);            -- Slice Of Land Crab Meat (Despoil)
INSERT INTO `mob_droplist` VALUES (3515,4,0,1000,881,0);             -- Crab Shell (Despoil)

-- 3516 = 2102 one bracket down (River_Crab z116)
INSERT INTO `mob_droplist` VALUES (3516,0,0,1000,936,100);           -- Chunk Of Rock Salt (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3516,0,0,1000,1016,50);           -- Remi Shell (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3516,0,0,1000,4400,5);            -- Slice Of Land Crab Meat (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3516,2,0,1000,936,0);             -- Chunk Of Rock Salt (Steal)
INSERT INTO `mob_droplist` VALUES (3516,4,0,1000,4400,0);            -- Slice Of Land Crab Meat (Despoil)
INSERT INTO `mob_droplist` VALUES (3516,4,0,1000,881,0);             -- Crab Shell (Despoil)

-- 3517 = 2120 one bracket down (Rock_Lizard z106)
INSERT INTO `mob_droplist` VALUES (3517,0,0,1000,926,100);           -- Lizard Tail (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3517,2,0,1000,926,0);             -- Lizard Tail (Steal)
INSERT INTO `mob_droplist` VALUES (3517,4,0,1000,852,0);             -- Lizard Skin (Despoil)
INSERT INTO `mob_droplist` VALUES (3517,4,0,1000,926,0);             -- Lizard Tail (Despoil)
INSERT INTO `mob_droplist` VALUES (3517,4,0,1000,4362,0);            -- Lizard Egg (Despoil)

-- 3518 = 2174 one bracket down (Scarab_Beetle z101)
INSERT INTO `mob_droplist` VALUES (3518,0,0,1000,846,50);            -- Insect Wing (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3518,0,0,1000,894,5);             -- Beetle Jaw (1% -> 0.5%)
INSERT INTO `mob_droplist` VALUES (3518,4,0,1000,846,0);             -- Insect Wing (Despoil)
INSERT INTO `mob_droplist` VALUES (3518,4,0,1000,889,0);             -- Beetle Shell (Despoil)
INSERT INTO `mob_droplist` VALUES (3518,4,0,1000,894,0);             -- Beetle Jaw (Despoil)

-- 3519 = 2419 one bracket down (Tiny_Mandragora z115, Tiny_Mandragora z116)
INSERT INTO `mob_droplist` VALUES (3519,0,0,1000,4368,50);           -- Two-Leaf Mandragora Bud (quest item, unchanged)
INSERT INTO `mob_droplist` VALUES (3519,2,0,1000,4368,0);            -- Two-Leaf Mandragora Bud (Steal)
INSERT INTO `mob_droplist` VALUES (3519,4,0,1000,4368,0);            -- Two-Leaf Mandragora Bud (Despoil)
INSERT INTO `mob_droplist` VALUES (3519,4,0,1000,834,0);             -- Ball Of Saruta Cotton (Despoil)

-- 3520 = 2496 one bracket down (Tunnel_Worm z100, Tunnel_Worm z101, Tunnel_Worm z106, Tunnel_Worm z107)
INSERT INTO `mob_droplist` VALUES (3520,0,0,1000,768,100);           -- Flint Stone (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3520,2,0,1000,17296,0);           -- Pebble (Steal)
INSERT INTO `mob_droplist` VALUES (3520,4,0,1000,640,0);             -- Chunk Of Copper Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3520,4,0,1000,643,0);             -- Chunk Of Iron Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3520,4,0,1000,736,0);             -- Chunk Of Silver Ore (Despoil)
INSERT INTO `mob_droplist` VALUES (3520,4,0,1000,642,0);             -- Chunk Of Zinc Ore (Despoil)

-- 3521 = 2603 one bracket down (Walking_Sapling z107)
INSERT INTO `mob_droplist` VALUES (3521,0,0,1000,953,100);           -- Treant Bulb (15% -> 10%)
INSERT INTO `mob_droplist` VALUES (3521,0,0,1000,575,50);            -- Bag Of Grain Seeds (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3521,0,0,1000,573,10);            -- Bag Of Vegetable Seeds (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3521,2,0,1000,575,0);             -- Bag Of Grain Seeds (Steal)
INSERT INTO `mob_droplist` VALUES (3521,4,0,1000,573,0);             -- Bag Of Vegetable Seeds (Despoil)
INSERT INTO `mob_droplist` VALUES (3521,4,0,1000,953,0);             -- Treant Bulb (Despoil)
INSERT INTO `mob_droplist` VALUES (3521,4,0,1000,2235,0);            -- Bag Of Wildgrass Seeds (Despoil)

-- 3522 = 2846 one bracket down (Savanna_Rarab z115)
INSERT INTO `mob_droplist` VALUES (3522,0,0,1000,856,50);            -- Rabbit Hide (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3522,0,0,1000,584,50);            -- Torn Epistle (quest item, unchanged)
INSERT INTO `mob_droplist` VALUES (3522,2,0,1000,4358,0);            -- Slice Of Hare Meat (Steal)
INSERT INTO `mob_droplist` VALUES (3522,4,0,1000,856,0);             -- Rabbit Hide (Despoil)
INSERT INTO `mob_droplist` VALUES (3522,4,0,1000,4358,0);            -- Slice Of Hare Meat (Despoil)

-- 3523 = 3227 one bracket down (Crawler z115)
INSERT INTO `mob_droplist` VALUES (3523,0,0,1000,816,50);            -- Spool Of Silk Thread (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3523,0,0,1000,1156,50);           -- Crawler Calculus (10% -> 5%)
INSERT INTO `mob_droplist` VALUES (3523,0,0,1000,583,10);            -- Smooth Stone (5% -> 1%)
INSERT INTO `mob_droplist` VALUES (3523,0,0,1000,582,50);            -- Meteorite (quest item, unchanged)
INSERT INTO `mob_droplist` VALUES (3523,4,0,1000,839,0);             -- Piece Of Crawler Cocoon (Despoil)
INSERT INTO `mob_droplist` VALUES (3523,4,0,1000,4357,0);            -- Crawler Egg (Despoil)

-- Point the capped groups at their shadow lists.
-- West Ronfaure (Zone 100)
UPDATE `mob_groups` SET `dropid` = 3511 WHERE `zoneid` = 100 AND `groupid` = 6; -- Wild_Rabbit
UPDATE `mob_groups` SET `dropid` = 3520 WHERE `zoneid` = 100 AND `groupid` = 7; -- Tunnel_Worm
UPDATE `mob_groups` SET `dropid` = 3504 WHERE `zoneid` = 100 AND `groupid` = 10; -- Carrion_Worm
UPDATE `mob_groups` SET `dropid` = 3515 WHERE `zoneid` = 100 AND `groupid` = 27; -- River_Crab
UPDATE `mob_groups` SET `dropid` = 3509 WHERE `zoneid` = 100 AND `groupid` = 15; -- Forest_Funguar
UPDATE `mob_groups` SET `dropid` = 3502 WHERE `zoneid` = 100 AND `groupid` = 18; -- Wild_Sheep

-- East Ronfaure (Zone 101)
UPDATE `mob_groups` SET `dropid` = 3510 WHERE `zoneid` = 101 AND `groupid` = 6; -- Wild_Rabbit
UPDATE `mob_groups` SET `dropid` = 3520 WHERE `zoneid` = 101 AND `groupid` = 7; -- Tunnel_Worm
UPDATE `mob_groups` SET `dropid` = 3511 WHERE `zoneid` = 101 AND `groupid` = 9; -- Forest_Hare
UPDATE `mob_groups` SET `dropid` = 3509 WHERE `zoneid` = 101 AND `groupid` = 11; -- Forest_Funguar
UPDATE `mob_groups` SET `dropid` = 3518 WHERE `zoneid` = 101 AND `groupid` = 12; -- Scarab_Beetle
UPDATE `mob_groups` SET `dropid` = 3502 WHERE `zoneid` = 101 AND `groupid` = 18; -- Wild_Sheep

-- North Gustaberg (Zone 106)
UPDATE `mob_groups` SET `dropid` = 3512 WHERE `zoneid` = 106 AND `groupid` = 6; -- Huge_Hornet
UPDATE `mob_groups` SET `dropid` = 3520 WHERE `zoneid` = 106 AND `groupid` = 7; -- Tunnel_Worm
UPDATE `mob_groups` SET `dropid` = 3506 WHERE `zoneid` = 106 AND `groupid` = 18; -- River_Crab
UPDATE `mob_groups` SET `dropid` = 3501 WHERE `zoneid` = 106 AND `groupid` = 21; -- Vulture
UPDATE `mob_groups` SET `dropid` = 3504 WHERE `zoneid` = 106 AND `groupid` = 10; -- Stone_Eater
UPDATE `mob_groups` SET `dropid` = 3514 WHERE `zoneid` = 106 AND `groupid` = 11; -- Ornery_Sheep
UPDATE `mob_groups` SET `dropid` = 3517 WHERE `zoneid` = 106 AND `groupid` = 19; -- Rock_Lizard

-- South Gustaberg (Zone 107)
UPDATE `mob_groups` SET `dropid` = 3512 WHERE `zoneid` = 107 AND `groupid` = 7; -- Huge_Hornet
UPDATE `mob_groups` SET `dropid` = 3520 WHERE `zoneid` = 107 AND `groupid` = 8; -- Tunnel_Worm
UPDATE `mob_groups` SET `dropid` = 3508 WHERE `zoneid` = 107 AND `groupid` = 10; -- Maneating_Hornet
UPDATE `mob_groups` SET `dropid` = 3504 WHERE `zoneid` = 107 AND `groupid` = 11; -- Stone_Eater
UPDATE `mob_groups` SET `dropid` = 3521 WHERE `zoneid` = 107 AND `groupid` = 21; -- Walking_Sapling
UPDATE `mob_groups` SET `dropid` = 3501 WHERE `zoneid` = 107 AND `groupid` = 22; -- Vulture
UPDATE `mob_groups` SET `dropid` = 3506 WHERE `zoneid` = 107 AND `groupid` = 30; -- Land_Crab

-- West Sarutabaruta (Zone 115)
UPDATE `mob_groups` SET `dropid` = 3519 WHERE `zoneid` = 115 AND `groupid` = 6; -- Tiny_Mandragora
UPDATE `mob_groups` SET `dropid` = 3503 WHERE `zoneid` = 115 AND `groupid` = 7; -- Bumblebee
UPDATE `mob_groups` SET `dropid` = 3522 WHERE `zoneid` = 115 AND `groupid` = 8; -- Savanna_Rarab
UPDATE `mob_groups` SET `dropid` = 3506 WHERE `zoneid` = 115 AND `groupid` = 9; -- River_Crab
UPDATE `mob_groups` SET `dropid` = 3508 WHERE `zoneid` = 115 AND `groupid` = 23; -- Giant_Bee
UPDATE `mob_groups` SET `dropid` = 3507 WHERE `zoneid` = 115 AND `groupid` = 10; -- Crawler
UPDATE `mob_groups` SET `dropid` = 3523 WHERE `zoneid` = 115 AND `groupid` = 22; -- Crawler

-- East Sarutabaruta (Zone 116)
UPDATE `mob_groups` SET `dropid` = 3519 WHERE `zoneid` = 116 AND `groupid` = 6; -- Tiny_Mandragora
UPDATE `mob_groups` SET `dropid` = 3503 WHERE `zoneid` = 116 AND `groupid` = 7; -- Bumblebee
UPDATE `mob_groups` SET `dropid` = 3500 WHERE `zoneid` = 116 AND `groupid` = 10; -- Carrion_Crow
UPDATE `mob_groups` SET `dropid` = 3516 WHERE `zoneid` = 116 AND `groupid` = 19; -- River_Crab
UPDATE `mob_groups` SET `dropid` = 3513 WHERE `zoneid` = 116 AND `groupid` = 20; -- Mandragora
UPDATE `mob_groups` SET `dropid` = 3508 WHERE `zoneid` = 116 AND `groupid` = 21; -- Giant_Bee
UPDATE `mob_groups` SET `dropid` = 3505 WHERE `zoneid` = 116 AND `groupid` = 56; -- Pug_Pugil

-- The extra level 1 mobs. Groups 200/201, no loot, instant respawn.

-- West Ronfaure (Zone 100)
INSERT INTO `mob_groups` VALUES (200, 4343, 100, 'Wild_Rabbit', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 4053, 100, 'Tunnel_Worm', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187690, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -718.9960, -60.1810, 587.4630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187691, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -103.2300, -60.8430, 205.0670, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187692, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -499.0200, -50.7490, 240.6480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187693, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -195.0870, -20.5570, -149.7340, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187694, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -376.6180, -31.0740, 29.5910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187695, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -222.0000, -11.0000, -392.0000, 62, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187696, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -383.0820, -17.7550, -214.6200, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187697, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -267.4090, -2.4770, -569.1170, 63, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187698, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -495.2170, -11.4820, -349.5630, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187699, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -412.9320, -56.5220, 390.4160, 104, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187700, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -556.9510, -0.7590, -494.3870, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187701, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -145.7180, -20.3050, -270.8070, 7, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187702, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -273.7180, -21.1520, -272.1190, 111, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187703, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -332.7220, -21.0320, -112.0440, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187704, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -326.7480, -14.3680, -428.1660, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187705, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -303.7890, -50.5960, 383.5830, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187706, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -402.6300, -52.4600, 257.5210, 98, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187707, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -367.2940, -11.1330, -308.0430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187708, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -499.6460, -30.8450, -3.5090, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187709, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -206.7500, -61.1570, 435.5400, 78, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187710, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -588.4940, -28.9920, -55.0020, 44, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187711, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -295.6260, -21.3890, -192.1910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187712, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -323.0280, -2.6280, -509.9470, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187713, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -326.1020, -41.1790, 106.2630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187714, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -342.1500, -51.2400, 207.0240, 108, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187715, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -148.4170, -21.8650, -91.3810, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187716, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -138.9360, -10.8680, -412.4830, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187717, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -36.7480, -0.7440, -449.2760, 92, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187718, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -312.3020, -11.1640, -359.6210, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187719, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -263.1190, -23.0780, -104.7810, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187720, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -524.4730, -30.3150, -74.3620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187721, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -193.0950, -22.4730, -224.2140, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187722, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -473.4640, -40.4490, 153.4900, 119, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187723, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -44.5650, -57.1330, 188.7430, 59, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187724, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -335.3480, -60.4510, 432.8680, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187725, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -97.8480, -0.8250, -498.4000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187726, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -330.5360, -18.7750, -236.4440, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187727, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -552.7420, -1.4850, -430.4620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187728, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -383.6450, -0.9980, -524.8070, 69, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187729, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -155.2530, -52.1340, 189.0740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187730, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -133.0010, -20.6360, -141.1100, 81, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187731, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -226.0970, -17.8250, -299.9580, 87, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187732, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -258.9930, -2.2850, -507.1740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187733, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -262.5140, -40.5880, 74.9480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187734, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -537.1480, -20.7300, -163.9450, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187735, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -226.4810, -34.3690, 18.0270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187736, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -176.6030, -11.7310, -384.8570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187737, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -404.7160, -50.1070, 206.4250, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187738, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -567.1640, -27.5940, -94.9030, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187739, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -362.2260, -10.1710, -485.2120, 6, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187740, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -369.6170, -51.1330, 384.8050, 95, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187741, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -73.0640, -51.0900, 155.8780, 40, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187742, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -242.7540, -11.5870, -429.5970, 57, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187743, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -325.4150, -50.1640, 347.5860, 18, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187744, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -317.0000, -9.0000, -469.0000, 61, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187745, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -286.3740, -40.8940, 108.3780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187746, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -245.6640, -60.8490, 438.2140, 6, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187747, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -285.1190, -20.5040, -235.1540, 31, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187748, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -132.8280, -0.6260, -519.4060, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187749, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -126.0000, -0.0100, -475.0000, 93, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187750, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -392.7870, -48.2610, 347.6560, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187751, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -236.8390, -20.6010, -127.9550, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187752, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -469.6900, -34.4970, 97.2970, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187753, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -282.7810, -21.4300, -132.3010, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187754, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -422.4090, -12.2000, -357.2270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187755, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -257.3620, -50.3510, 277.9630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187756, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -281.7790, -31.0000, -77.8740, 73, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187757, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -511.6730, -9.7640, -402.8390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187758, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -436.0240, -38.1980, 143.9180, 71, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187759, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -558.0240, -59.1340, 404.2870, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187760, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -530.7740, -31.0900, -10.9660, 7, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187761, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -26.9590, -0.5920, -479.5540, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187762, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -254.8370, -49.8130, 185.4730, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187763, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -457.9000, -23.6350, -65.9640, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187764, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, -529.8070, -0.0140, -507.8870, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187765, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -46.1440, -0.0040, -522.1120, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187766, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -581.3550, -21.5680, -148.8100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187767, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -420.5890, -3.8550, -484.5020, 15, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187768, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -279.6940, -61.3990, 487.5120, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187769, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -508.7710, -60.6010, 488.6170, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187770, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -290.1120, -51.7580, 283.0100, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187771, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -585.1410, -29.7810, 30.1440, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187772, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -248.5190, -48.4800, 120.8130, 6, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187773, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -71.4180, -13.1270, -387.1060, 49, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187774, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -452.2080, -22.3150, -96.4550, 89, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187775, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -627.7060, -53.5350, 269.0650, 17, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187776, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -207.4360, -31.4800, -23.8770, 88, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187777, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -408.6280, -41.1860, 161.1900, 76, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187778, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -162.8090, -0.6320, -486.6020, 90, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187779, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -522.4880, -30.9940, 115.2680, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187780, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -509.1040, -50.3480, 363.4340, 51, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187781, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -603.1100, -60.4040, 507.5730, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187782, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -282.7830, -30.5620, 30.7240, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187783, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -573.8380, -41.7630, 189.1160, 108, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187784, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -240.1370, -50.7900, 213.0720, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187785, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -449.3110, -32.7570, 69.6780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187786, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -497.0100, 0.7010, -431.8080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187787, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -427.3680, -11.0730, -390.6580, 120, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187788, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -658.3270, -31.0160, 0.7940, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187789, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -328.8510, -31.2240, -30.5480, 53, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187790, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -453.2050, -19.5160, -193.2340, 39, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187791, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -458.8590, -52.4730, 312.5030, 2, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187792, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -398.1800, -30.4480, -43.7450, 36, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187793, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -184.5000, -19.8750, -329.0640, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187794, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -567.1100, -48.0850, 303.3850, 55, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187795, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -227.0000, -0.0100, -469.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187796, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -541.1310, -60.2510, 431.6930, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187797, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -262.3820, -57.5760, 338.5120, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187798, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -348.5630, -52.0220, 290.4220, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187799, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -399.0080, -32.9570, 96.4410, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187800, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -390.4480, -10.0420, -433.2740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187801, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -471.8410, -50.3400, 405.3050, 8, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187802, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -248.6810, -21.3360, -163.9870, 98, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187803, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -399.1980, -51.4900, 312.0410, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187804, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -451.7380, -31.8960, -28.3480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187805, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -512.2800, -50.7240, 312.4620, 15, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187806, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -294.9160, -48.8070, 224.7110, 53, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187807, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -311.0530, -8.9170, -304.8980, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187808, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -413.9970, -11.1510, -314.4900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187809, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -366.4930, -11.5530, -393.2260, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187810, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -167.9490, -0.4170, -532.2810, 116, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187811, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -461.5100, -2.8920, -464.8230, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187812, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -335.2450, -32.1560, 48.1950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187813, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -361.1320, -21.6300, -69.6500, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187814, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -174.1230, -10.6460, -443.7630, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187815, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -548.7270, -49.1090, 263.8250, 24, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187816, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -551.5990, -57.7210, 492.9200, 51, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187817, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -511.6880, -30.8090, 74.2600, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187818, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -568.0570, -29.1790, -7.7680, 38, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187819, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -294.5400, -59.8570, 427.8960, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187820, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -183.4060, -17.5490, -280.8910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187821, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -328.2790, -52.6610, 257.1370, 96, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187822, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -241.8070, -62.0610, 482.5540, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187823, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -190.0910, -21.5070, -113.2760, 83, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187824, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -347.2720, -31.6320, 8.1590, 87, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187825, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -317.4060, -52.4940, 308.6910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187826, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -278.4210, -11.6910, -351.4250, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187827, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -440.7900, -10.6990, -422.0780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187828, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -392.6500, -30.7760, 59.3670, 65, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187829, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -570.5980, -3.0470, -458.5970, 90, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187830, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -373.3000, -52.5030, 218.2480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187831, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -155.5870, -20.8380, -239.8600, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187832, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -495.1890, -41.3310, 208.4640, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187833, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -404.0820, -39.3440, 129.2660, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187834, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -487.6280, -47.0400, 339.4950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187835, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -341.6440, -51.0490, 400.3530, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187836, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -230.9160, -18.1610, -331.3860, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187837, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -214.1860, -51.2760, 195.8380, 53, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187838, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -364.5570, -11.1640, -277.3560, 102, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17187839, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -612.9070, -51.8760, 295.1110, 71, NULL, NULL);

-- East Ronfaure (Zone 101)
INSERT INTO `mob_groups` VALUES (200, 4343, 101, 'Wild_Rabbit', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 4053, 101, 'Tunnel_Worm', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191786, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 2.0550, -51.7790, 171.8880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191787, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 768.7190, -60.4780, 618.1050, 71, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191788, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 83.1620, -2.4720, -514.4560, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191789, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 332.1540, -22.5080, -223.9770, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191790, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 289.2510, -51.7160, 208.1000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191791, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 165.0100, -34.8790, -22.5060, 49, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191792, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 373.6190, -37.0930, 8.8110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191793, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 154.7250, -60.5670, 325.4000, 28, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191794, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 453.6250, -18.4360, -127.0480, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191795, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 150.3740, -56.4650, 137.0900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191796, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 433.5910, -60.9110, 390.5740, 76, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191797, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 295.8230, -31.8160, -97.5690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191798, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 463.4280, -7.5980, -485.6140, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191799, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 495.9850, -39.1480, -6.6460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191800, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 259.5540, -39.3450, 94.0380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191801, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 191.0080, -60.4630, 431.7650, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191802, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 511.0260, -50.5210, 191.2700, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191803, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 537.7600, -50.6790, 313.6300, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191804, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 177.4230, -8.3000, -417.3410, 74, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191805, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 319.0430, -20.4310, -341.6460, 81, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191806, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 256.1030, -50.1710, 285.0010, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191807, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 183.5340, -26.2780, -101.3080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191808, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 404.7120, -20.6730, -199.0100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191809, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 508.2610, -10.6040, -413.3910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191810, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 579.9460, -51.4040, 167.4720, 104, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191811, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 345.9580, -47.2390, 164.0750, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191812, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 394.0930, -50.5110, 76.7830, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191813, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 663.5870, -60.0710, 418.1890, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191814, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 472.3290, -50.7780, 335.3610, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191815, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 486.6190, -39.7000, 59.4450, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191816, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 84.3180, -53.9670, 134.2740, 83, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191817, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 632.6290, -11.0200, -474.3460, 112, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191818, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 328.8690, -6.6100, -418.0200, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191819, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 516.8780, -56.4860, 383.0290, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191820, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 448.4470, -10.7320, -417.6600, 23, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191821, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 315.1300, -21.4390, -150.7010, 125, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191822, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 270.3080, -50.1230, 156.4110, 36, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191823, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 452.6560, -16.9880, -223.5460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191824, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 408.8250, -19.6330, -260.6230, 12, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191825, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 238.2840, -60.6310, 330.3430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191826, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 222.0000, -47.0000, 156.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191827, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 459.3450, -6.6860, -363.8420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191828, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 524.6590, -60.6300, 448.1150, 112, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191829, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 326.8990, -20.4750, -275.4110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191830, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 422.2020, -19.9160, -327.7480, 77, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191831, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 305.6630, -0.9270, -493.4460, 73, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191832, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 103.3670, -49.5320, 96.0270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191833, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 50.6840, -53.5750, 157.1390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191834, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 231.2860, -60.0280, 429.9290, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191835, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 238.0000, -57.0000, 380.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191836, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 359.8780, -18.4400, -252.6850, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191837, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 413.2290, -38.4670, 7.0470, 10, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191838, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 175.9640, -56.6240, 166.8830, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191839, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 479.6060, -60.4980, 409.9910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191840, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 326.7730, -40.3340, 10.1580, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191841, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 195.1400, -32.8960, -65.0830, 105, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191842, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 754.7180, -61.4900, 495.1850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191843, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 62.0380, -61.1230, 197.4200, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191844, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 561.4880, -61.5360, 443.4830, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191845, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 275.6100, -60.4580, 405.0420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191846, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 628.1030, -62.4740, 412.1700, 58, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191847, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 549.7970, -50.7260, 149.7630, 90, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191848, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 567.6650, -51.9250, 330.3500, 24, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191849, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 211.1570, -60.4370, 296.7240, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191850, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 235.0120, -3.2170, -424.2660, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191851, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 495.3630, -48.2540, 162.0080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191852, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 517.9780, -31.8520, -31.0630, 67, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191853, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 526.9430, -60.6550, 415.4170, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191854, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 427.5670, -10.1610, -388.7670, 107, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191855, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 208.5410, -60.7060, 405.0600, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191856, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 400.1810, -20.8040, -299.6330, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191857, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 152.5220, -50.2490, 106.6000, 95, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191858, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 171.5180, -60.2030, 300.7020, 100, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191859, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 227.1760, -40.2210, 16.8560, 70, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191860, 0, 'Wild_Rabbit', 'Wild Rabbit', 200, 1, 1, 125.3950, -60.0910, 155.1650, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191861, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 632.2420, -12.0330, -540.0190, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191862, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 554.9040, -50.1380, 98.6650, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191863, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 295.2470, -61.7610, 490.6550, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191864, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 575.3380, -62.0210, 403.7950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191865, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 345.1410, -1.0020, -527.7380, 124, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191866, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 564.7870, -20.6290, -311.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191867, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 168.3330, -19.1690, -329.9560, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191868, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 402.0370, -10.5100, -368.5260, 86, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191869, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 716.5200, -61.9570, 463.5090, 109, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191870, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 421.0830, -48.0950, 147.6120, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191871, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 625.6910, -50.8970, 270.6520, 80, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191872, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 266.3540, -9.1110, -412.3850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191873, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 276.4530, -60.3490, 368.5630, 115, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191874, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 580.7570, -12.0620, -429.8750, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191875, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 238.7880, -0.9370, -519.5670, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191876, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 465.8710, -20.8940, -279.9780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191877, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 239.8500, -20.7900, -260.2690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191878, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 280.9270, -40.7590, 3.2310, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191879, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 781.3290, -61.0260, 522.0120, 62, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191880, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 98.6600, -58.1760, 205.1850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191881, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 208.3160, -50.4470, 201.5100, 67, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191882, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 519.8940, -20.7680, -224.7010, 50, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191883, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 151.8320, -48.8890, 51.6220, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191884, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 477.6780, -60.5940, 449.0080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191885, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 151.5780, -0.5570, -484.8780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191886, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 616.6680, -57.3550, 341.6280, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191887, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 570.9080, -9.4240, -506.8540, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191888, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 369.4850, -20.4990, -294.4620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191889, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 234.1430, -20.2020, -342.0690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191890, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 190.6220, -59.3760, 269.8250, 63, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191891, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 503.8250, -9.1650, -347.8600, 120, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191892, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 304.7510, -58.4480, 426.3770, 16, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191893, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 213.3030, -40.4580, 42.8260, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191894, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 333.1340, -38.4250, -35.5910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191895, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 320.2700, -40.6570, 47.8430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191896, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 318.1840, -46.8130, 103.6910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191897, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 267.0120, 0.9220, -473.6950, 3, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191898, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 456.1470, -27.7750, -73.5370, 101, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191899, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 210.4160, -48.3110, 108.8400, 100, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191900, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 283.9290, -20.8150, -240.9510, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191901, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 193.0560, -10.5950, -372.5950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191902, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 379.1200, -27.8980, -46.4360, 17, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191903, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 534.8810, -10.3810, -477.0780, 102, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191904, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 464.4910, -18.9890, -172.0130, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191905, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 137.7090, -57.7510, 180.7340, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191906, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 165.0810, -60.5930, 397.4310, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191907, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 596.4220, -48.8980, 306.2040, 204, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191908, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 363.1190, -42.0080, 50.7880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191909, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 253.5520, -39.7340, 41.6290, 59, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191910, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 263.8450, -50.8830, 238.9560, 43, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191911, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 179.4760, -41.7910, 14.6000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191912, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 281.7110, -20.5830, -354.0800, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191913, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 257.7480, -25.8700, -107.1560, 75, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191914, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 369.4670, -19.6340, -333.4430, 96, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191915, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 462.8540, -33.2690, -25.7420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191916, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 561.9810, -51.0300, 200.8240, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191917, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 652.8260, -47.0570, 296.7200, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191918, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 515.5150, -50.3220, 345.8150, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191919, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 156.4600, -10.6740, -375.5690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191920, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 697.1070, -61.8960, 405.0460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191921, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 298.6200, -40.2990, -41.2690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191922, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 145.2140, -43.9970, 14.1610, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191923, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 540.4050, -7.5310, -424.2580, 94, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191924, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 241.7610, -49.7570, 206.5200, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191925, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 570.5560, -6.5440, -461.6400, 58, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191926, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 654.5520, -14.2470, -499.1550, 19, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191927, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 303.0730, -50.8160, 157.5920, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191928, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 479.3020, -20.7440, -204.4740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191929, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 443.3340, -17.0000, -303.2750, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191930, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 431.2560, -19.9660, -181.5230, 108, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191931, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 286.3830, -60.1440, 451.3460, 6, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191932, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 682.3660, -60.8030, 442.1440, 117, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191933, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 352.2420, -37.9520, -13.1270, 115, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191934, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 442.9130, -49.6730, 128.2500, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17191935, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 709.5520, -64.8530, 430.4550, 127, NULL, NULL);

-- North Gustaberg (Zone 106)
INSERT INTO `mob_groups` VALUES (200, 2000, 106, 'Huge_Hornet', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 4053, 106, 'Tunnel_Worm', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212266, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -660.1510, 42.2720, 379.1110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212267, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 310.2770, -30.4780, 1065.6800, 105, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212268, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -32.0370, -0.9290, 607.3630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212269, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 380.2480, -20.4060, 641.4140, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212270, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -328.1140, 42.7170, 449.9490, 72, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212271, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -170.3290, 2.5210, 258.6600, 31, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212272, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 524.1410, -1.0360, 461.2840, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212273, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -474.5210, 38.2810, 342.1590, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212274, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 175.3150, -20.5690, 582.7280, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212275, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 352.2310, -40.4630, 449.7820, 37, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212276, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 66.4440, -0.9790, 284.1670, 74, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212277, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 228.5820, 2.5770, 258.8640, 37, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212278, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 290.5440, -2.6380, 840.5520, 76, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212279, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 446.2020, -0.8420, 362.6100, 52, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212280, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 276.4560, -20.7570, 712.2850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212281, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -47.6070, 0.0910, 276.0500, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212282, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 308.1160, -60.3520, 550.7710, 27, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212283, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -472.1500, 40.1930, 142.4780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212284, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 249.9120, -19.5230, 982.7280, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212285, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 437.4970, -1.0610, 558.5920, 25, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212286, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 50.1080, -0.0420, 556.1920, 13, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212287, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 654.2900, -4.3620, 460.7220, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212288, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -549.5670, 40.0030, -15.0430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212289, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -408.4930, 38.8510, 489.7000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212290, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -472.1450, 49.2930, 45.6520, 10, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212291, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 113.6450, -20.7930, 460.2130, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212292, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 439.1330, -20.7220, 443.9960, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212293, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -272.1080, 39.7000, 392.4050, 104, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212294, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -25.1840, 0.7840, 118.1370, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212295, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 377.8590, 1.6150, 333.4450, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212296, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 540.4570, -7.6810, 611.9010, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212297, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -252.9760, -2.9380, 218.5170, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212298, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -469.7130, 39.5040, 460.6500, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212299, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 317.0310, -0.8290, 200.9520, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212300, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 122.4050, -20.4780, 544.0600, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212301, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -450.8640, 51.4370, -26.6700, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212302, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -616.3270, 38.7710, 443.9840, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212303, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 294.2880, -40.1930, 430.8490, 86, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212304, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 605.1920, 1.2780, 425.5530, 65, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212305, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 51.3570, -0.9090, 415.3320, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212306, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 238.0640, -20.7780, 322.3830, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212307, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 363.9730, -40.7740, 562.3550, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212308, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 150.1070, -0.4650, 652.3120, 2, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212309, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -18.4290, 2.3340, 488.8570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212310, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 507.2540, -8.2000, 681.2240, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212311, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 201.3420, -40.5320, 508.1010, 85, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212312, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 335.9430, -60.3190, 507.1480, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212313, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 239.0000, -20.0000, 640.0000, 72, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212314, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 277.8860, -0.6450, 236.3910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212315, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -138.3990, -0.2850, 395.9590, 2, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212316, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 104.0070, 1.9990, 254.6720, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212317, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 211.2590, -20.3060, 361.4020, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212318, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 13.0760, 1.9170, 146.6930, 16, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212319, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -507.2410, 40.1320, 115.5920, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212320, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -467.6620, 40.2660, 89.3620, 70, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212321, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -370.4070, 41.0480, 460.2620, 117, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212322, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -130.5990, 0.0740, 119.1790, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212323, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -435.4000, 48.6070, 23.6840, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212324, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 406.1660, -2.3370, 301.6920, 13, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212325, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -154.1140, -0.5530, 437.6740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212326, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 203.6060, -0.6070, 721.5410, 86, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212327, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 349.5590, -30.5340, 1077.5900, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212328, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -523.0010, 39.3690, 318.3810, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212329, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 285.8130, -60.7840, 518.5390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212330, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 149.4120, -19.8950, 429.1940, 46, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212331, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 349.2980, -20.2140, 663.7930, 84, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212332, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 261.5930, -0.5400, 293.1560, 19, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212333, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -380.8430, 47.7500, -28.8290, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212334, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 410.9460, -0.7360, 369.7320, 107, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212335, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -537.1270, 42.2650, 17.6900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212336, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -309.4360, 40.4490, 242.2570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212337, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 348.5550, 2.1700, 258.4820, 95, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212338, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 676.6080, -0.6370, 437.1120, 87, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212339, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 248.7300, -19.9290, 352.6120, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212340, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -31.5950, -0.1350, 517.6290, 118, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212341, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 760.3690, -1.1090, 440.3860, 105, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212342, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 50.0150, -0.6670, 120.2020, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212343, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -394.5670, 47.0320, 4.7690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212344, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 396.3690, -0.6960, 223.9700, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212345, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 171.8940, -20.7300, 398.0630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212346, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 170.2520, 0.9720, 761.2540, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212347, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 561.8920, -11.5740, 682.5010, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212348, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -6.6690, 0.0580, 423.0160, 100, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212349, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -555.0200, 40.1160, 79.0870, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212350, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -322.5890, 40.5110, 210.6120, 79, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212351, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -99.1420, 1.9750, 82.6110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212352, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -185.6080, -1.0380, 409.2550, 34, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212353, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 642.4430, -0.0390, 366.5340, 64, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212354, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -553.1500, 39.2340, 442.0160, 250, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212355, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -610.1870, 39.3900, 273.4960, 3, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212356, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 278.8900, -20.5450, 363.4060, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212357, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -315.4470, 39.7240, 317.9240, 25, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212358, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 94.5210, 2.3650, 648.4390, 124, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212359, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -72.0280, -0.6880, 500.2050, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212360, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 237.7530, -40.5000, 469.7380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212361, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 542.0930, -1.3030, 352.7700, 109, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212362, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -87.6290, -20.9810, 176.3700, 103, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212363, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -269.6490, 39.8780, 521.0240, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212364, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 316.6440, 0.8540, 266.6370, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212365, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -167.0210, -0.9010, 142.7620, 85, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212366, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 197.6960, -20.6880, 679.9110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212367, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 345.0040, -30.7760, 991.8710, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212368, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 288.4470, -40.8420, 634.1610, 82, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212369, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 717.2680, -1.2460, 360.5530, 62, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212370, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -407.8820, 39.8140, 374.1880, 104, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212371, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 239.9920, -0.4930, 788.0370, 99, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212372, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 588.7060, -2.2620, 484.6780, 16, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212373, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 133.2030, 2.0190, 294.9030, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212374, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 241.9170, -40.4870, 587.8150, 36, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212375, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -69.2510, 2.4130, 337.2900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212376, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -563.7780, 39.5530, 317.0160, 60, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212377, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 336.6600, -0.3440, 722.8420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212378, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -117.3280, -0.7160, 288.0550, 8, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212379, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 233.0740, -1.7090, 853.4860, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212380, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 498.5150, 0.2220, 409.0130, 116, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212381, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 717.0370, -0.5030, 478.5740, 117, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212382, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 394.0920, -20.3840, 411.6390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212383, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -196.7630, -0.4880, 306.6740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212384, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -214.9080, -0.6200, 363.1170, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212385, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 34.8430, -0.2480, 505.4120, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212386, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 86.3740, -0.4570, 594.1080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212387, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 548.7760, 2.2500, 412.7060, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212388, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 312.0000, -20.0000, 678.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212389, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 368.3230, -2.0440, 183.7310, 83, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212390, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 679.8050, -0.5610, 396.5730, 18, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212391, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -594.7570, 40.0240, 401.7420, 95, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212392, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 403.2520, -20.6720, 601.3870, 74, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212393, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -281.0250, 39.5980, 289.9380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212394, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 197.9280, -20.3930, 620.4630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212395, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 397.4990, -20.9110, 456.7640, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212396, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 197.3690, -40.6120, 453.6880, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212397, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 158.1490, -40.7460, 520.4290, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212398, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 244.8520, -20.4600, 683.6520, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212399, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 357.9730, -30.5570, 1032.3200, 61, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212400, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -534.7550, 45.4510, 404.1600, 101, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212401, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -1.5000, -0.7860, 83.6300, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212402, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 203.6350, -40.5360, 553.2910, 4, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212403, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 289.7090, -0.2970, 750.2520, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212404, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -204.3650, -0.2210, 239.4630, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212405, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 441.9180, -0.5780, 596.6430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212406, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -10.6850, -0.6800, 282.8420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212407, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 306.6980, -20.1180, 387.9340, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212408, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -61.4020, -0.4330, 119.8430, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212409, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -177.3320, 2.5290, 109.1690, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212410, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 515.1880, -1.6070, 495.0210, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212411, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 556.9430, -0.5530, 457.7780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212412, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 266.6940, -0.1140, 806.9140, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212413, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 635.4180, -0.6970, 413.8520, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212414, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -621.7170, 40.1990, 303.2030, 8, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17212415, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 302.8090, -41.4050, 606.0490, 127, NULL, NULL);

-- South Gustaberg (Zone 107)
INSERT INTO `mob_groups` VALUES (200, 2000, 107, 'Huge_Hornet', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 4053, 107, 'Tunnel_Worm', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216362, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -561.1270, 39.4210, -394.8500, 67, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216363, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 127.0020, -0.3040, -168.7880, 109, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216364, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -211.4800, 10.8910, -327.8390, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216365, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 403.0590, -0.7260, -636.0920, 3, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216366, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 275.1350, -39.9770, -477.8400, 122, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216367, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 568.6830, -1.2400, -488.9040, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216368, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -438.7300, 39.7180, -257.3230, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216369, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -86.8260, 13.4350, -461.7130, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216370, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 551.8230, 0.1530, -662.0000, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216371, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 46.0750, 0.9620, -555.1630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216372, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 607.5120, -1.9110, -370.3880, 73, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216373, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 140.7960, -20.5160, -290.8580, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216374, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -341.1130, 32.8620, -333.1880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216375, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -109.8130, -0.0140, -170.3400, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216376, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -457.1070, 42.5930, -382.6820, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216377, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 28.3460, 0.9590, -125.2050, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216378, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 362.8200, -0.0720, -270.6620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216379, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 223.5900, -19.9020, -559.1400, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216380, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 528.4760, -0.6230, -328.9990, 2, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216381, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 223.8920, -0.7570, -199.8530, 114, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216382, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 492.7820, -0.0030, -525.0870, 76, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216383, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 0.9100, 1.9940, -428.3470, 87, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216384, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 512.4160, -1.1180, -726.8760, 77, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216385, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 156.8210, -40.0150, -415.9950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216386, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -506.2100, 39.7820, -328.2950, 32, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216387, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 463.6730, -20.2050, -590.3660, 26, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216388, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 203.8470, -39.6010, -493.4710, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216389, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -275.4410, 20.4510, -347.2940, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216390, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -121.2160, 10.4330, -327.1630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216391, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 277.8910, -39.8540, -413.3540, 103, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216392, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 486.8710, 0.1630, -461.8770, 5, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216393, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 290.0270, 0.0080, -569.7610, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216394, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -36.4820, 9.2060, -492.3410, 37, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216395, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -388.9550, 37.5290, -383.6220, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216396, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -87.5820, 9.9470, -280.1480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216397, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 18.1240, 4.9020, -323.6760, 37, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216398, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 276.0000, -0.2630, -217.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216399, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 117.1840, -20.1080, -477.5810, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216400, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 98.7440, 0.3370, -631.8940, 17, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216401, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -114.7160, 4.1940, -223.2610, 64, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216402, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -512.6660, 40.1510, -410.8020, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216403, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 253.1590, -19.7890, -327.4980, 96, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216404, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 12.7750, 8.1310, -381.8570, 60, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216405, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 313.8680, 0.0190, -287.7890, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216406, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 604.6910, 0.0930, -559.7730, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216407, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 246.5330, 0.0320, -598.4470, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216408, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 590.0000, -1.0000, -412.0000, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216409, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 295.6160, -19.6750, -354.2680, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216410, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -448.9040, 42.8910, -336.3420, 61, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216411, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 394.9350, 0.0840, -564.7400, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216412, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 385.9570, 0.0070, -307.3370, 82, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216413, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 56.2160, -1.1460, -156.7710, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216414, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 566.2130, 2.2950, -374.2380, 98, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216415, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -455.7050, 42.7260, -296.2430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216416, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -77.6990, 0.8140, -193.8080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216417, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 527.4090, -0.5780, -368.2260, 93, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216418, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -403.2130, 39.5560, -289.5770, 8, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216419, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -35.0760, 9.7750, -418.6590, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216420, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 232.3970, 0.0150, -266.7770, 64, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216421, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -224.7770, 17.9580, -421.6270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216422, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 221.4620, -0.4320, -234.4660, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216423, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 220.3190, -19.9840, -319.2410, 126, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216424, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 416.0900, 1.1870, -512.9140, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216425, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -58.6350, 12.9320, -445.0110, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216426, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -482.7260, 40.1900, -350.5930, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216427, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 88.8220, 0.2520, -552.3380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216428, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 346.1510, -0.2660, -297.0030, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216429, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -23.0450, 2.6780, -179.8260, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216430, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 121.2930, -19.9420, -328.5260, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216431, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -116.3750, 19.7930, -461.8370, 68, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216432, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 24.7940, -0.0490, -445.4890, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216433, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -380.4610, 38.3090, -312.4570, 21, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216434, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 519.1820, -0.0160, -435.0460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216435, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, 669.4950, -3.1460, -650.6740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216436, 0, 'Huge_Hornet', 'Huge Hornet', 200, 1, 1, -270.0190, 20.6120, -389.9700, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216437, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 695.0650, -2.4740, -638.3040, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216438, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 136.3060, -0.4020, -669.9230, 29, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216439, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 436.9210, -0.4700, -342.9600, 53, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216440, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 82.8080, -19.8880, -424.9950, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216441, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -21.5270, -0.5880, -39.2220, 7, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216442, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -376.2730, 32.7760, -441.0780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216443, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 268.8380, 0.1780, -274.9460, 29, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216444, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -25.2110, 8.5420, -234.2400, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216445, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 421.2470, 0.0820, -479.5160, 96, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216446, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -539.9240, 39.5450, -524.8070, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216447, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 278.6250, 0.5260, -630.5450, 125, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216448, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -255.5200, 20.2430, -439.2600, 31, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216449, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -61.6090, 9.8270, -355.6940, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216450, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 218.0230, -39.9540, -363.1020, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216451, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 339.3850, -19.9570, -362.2570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216452, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 139.6530, -19.7660, -526.9900, 116, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216453, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -144.5230, 11.9510, -266.7040, 7, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216454, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 52.0630, 7.3620, -278.9910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216455, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 350.8260, -0.3060, -565.2440, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216456, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 561.8950, -0.0310, -577.0520, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216457, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 536.8280, 2.0060, -412.0250, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216458, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -475.1880, 42.5760, -462.3390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216459, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 340.4140, -19.8920, -436.9670, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216460, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 157.7950, -0.0080, -599.7900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216461, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 100.4160, -20.7090, -350.6460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216462, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 618.1890, -0.5100, -642.7520, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216463, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 53.4540, 0.4060, -488.1300, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216464, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -322.8710, 30.0520, -401.1840, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216465, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -405.4070, 39.6260, -327.3810, 43, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216466, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 153.0910, 2.0020, -227.9550, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216467, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 203.7610, -20.0540, -288.2500, 45, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216468, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -49.4180, 0.1300, -163.9730, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216469, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 366.4970, -0.4470, -508.4560, 85, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216470, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -419.2520, 39.4470, -480.4460, 52, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216471, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -111.7920, 12.7760, -411.4120, 37, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216472, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 164.2450, -39.9000, -347.8780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216473, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 9.1850, 0.8990, -191.6300, 126, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216474, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 100.7960, 2.0750, -216.2890, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216475, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 211.7450, -59.9380, -441.3130, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216476, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 110.6220, 0.6110, -578.7040, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216477, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -241.8950, 20.0160, -390.9360, 13, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216478, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 260.5310, -20.1270, -523.5470, 84, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216479, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 539.8630, 2.6150, -528.7730, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216480, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 654.6770, -1.7320, -613.8740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216481, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -172.6890, 11.2380, -351.7160, 117, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216482, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 7.6780, 9.8630, -270.1050, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216483, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 160.3040, -39.9900, -460.4000, 122, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216484, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 191.0000, -0.0100, -170.0000, 51, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216485, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -519.0150, 40.3420, -457.0710, 98, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216486, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 318.1980, -19.9270, -485.4160, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216487, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -432.0260, 39.9430, -439.8900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216488, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 74.2910, 0.2490, -524.7500, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216489, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 408.2300, 0.0400, -372.0400, 38, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216490, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 553.9090, 0.4350, -448.7070, 31, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216491, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 35.0490, 0.1800, -86.4130, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216492, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 587.2360, 2.3270, -619.3570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216493, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 1.5230, 0.2890, -151.2090, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216494, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -529.0800, 39.9390, -376.0790, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216495, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 294.4110, -20.1240, -511.4950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216496, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 385.6720, -0.5450, -606.3600, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216497, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 585.6060, -0.2070, -518.2770, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216498, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 504.0080, 2.3360, -491.0800, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216499, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 249.9700, -39.9470, -395.1770, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216500, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 334.8080, 0.3670, -253.9100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216501, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -533.5260, 38.9530, -344.4450, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216502, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 403.9090, -0.0600, -332.8230, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216503, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 260.9610, 0.1810, -244.7910, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216504, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 537.8900, 2.2470, -498.1680, 73, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216505, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 186.0810, -39.9900, -367.9420, 34, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216506, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -0.0500, -0.4050, -117.5280, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216507, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, 97.6780, -20.2250, -450.1200, 28, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216508, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -252.8080, 20.9500, -329.1270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216509, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -485.6810, 43.3340, -381.3100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216510, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -362.3930, 29.9850, -393.5300, 18, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17216511, 0, 'Tunnel_Worm', 'Tunnel Worm', 201, 1, 1, -155.8290, 11.1480, -329.8260, 127, NULL, NULL);

-- West Sarutabaruta (Zone 115)
INSERT INTO `mob_groups` VALUES (200, 3924, 115, 'Tiny_Mandragora', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 583, 115, 'Bumblebee', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249130, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -398.6220, 3.9260, -364.9700, 18, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249131, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -396.2530, -28.6610, 375.6570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249132, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 89.0000, 4.0000, -481.0000, 75, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249133, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -168.1390, -20.9560, 637.5690, 57, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249134, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 314.7900, -19.9040, 288.2760, 64, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249135, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 390.0560, -4.8990, 38.7920, 29, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249136, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 79.1120, -1.6080, -258.4940, 49, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249137, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -161.9350, -16.9040, 382.3790, 27, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249138, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 217.0000, -5.0000, 121.0000, 54, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249139, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -243.3630, -0.1960, -251.1880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249140, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -245.4880, -29.4770, 501.6220, 70, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249141, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -105.6140, -5.4320, -246.0140, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249142, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 154.5200, -32.6000, 281.8100, 126, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249143, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 59.3400, -0.2180, -123.7240, 102, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249144, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -284.5010, -20.0230, 324.2590, 80, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249145, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 359.3530, -7.6210, 148.0470, 2, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249146, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -32.0000, -16.0000, 424.0000, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249147, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 285.0000, -4.0000, 33.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249148, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 221.0000, -34.0000, 360.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249149, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -305.8690, 2.1140, -343.5170, 62, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249150, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -4.0000, -1.0000, -192.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249151, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -328.5830, -28.6760, 468.7650, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249152, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -194.3500, -1.3810, -337.2100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249153, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 194.1750, -22.2560, 214.7240, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249154, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -348.5500, -16.8610, 278.2090, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249155, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 119.0000, -30.0000, 378.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249156, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 246.9670, -24.9080, 261.9800, 47, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249157, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -308.5070, -17.8080, 388.1280, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249158, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 245.2930, -22.1250, 423.2820, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249159, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 354.5320, -20.3570, 356.2300, 6, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249160, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -3.0000, -4.0000, 80.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249161, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 301.0720, -5.1420, 117.6930, 105, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249162, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 121.1730, -1.1400, -99.8070, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249163, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 284.8300, -23.6680, 350.7170, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249164, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 53.2680, 0.1350, -316.7390, 119, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249165, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -1.4170, -1.0530, -414.1010, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249166, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -72.2220, -4.8130, -389.8660, 71, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249167, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -39.0000, -12.0000, 319.0000, 77, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249168, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 203.8520, -5.0160, -11.1640, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249169, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 120.9340, -35.0180, 324.1680, 53, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249170, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -289.6890, -1.3940, -276.7750, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249171, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 330.4590, -5.0120, 75.2350, 115, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249172, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 225.1190, -20.8280, 517.7970, 19, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249173, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 113.0860, -6.3530, 92.5580, 26, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249174, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 79.0000, -1.0000, -54.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249175, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 48.1900, -1.2310, -364.0850, 62, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249176, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -86.6800, -13.1550, 246.9500, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249177, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 170.4900, -5.1610, 85.1100, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249178, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 394.7670, -4.8110, 119.5130, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249179, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 274.2960, -20.3570, 587.3390, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249180, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -351.0000, -17.0000, 377.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249181, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -204.4730, -4.0370, -209.0630, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249182, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 76.9580, -22.9950, 373.2000, 106, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249183, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 116.7540, -0.1810, -35.8270, 90, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249184, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -202.4320, -16.8380, 372.7740, 61, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249185, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 157.0000, -40.0000, 363.0000, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249186, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -207.3330, -0.9900, -382.3930, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249187, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 306.4860, -6.9600, 156.7380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249188, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -332.5580, -16.7030, 312.9210, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249189, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 96.2580, -2.7050, 58.4180, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249190, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 218.2500, -20.6170, 554.1140, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249191, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 95.0000, -1.0000, -128.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249192, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 6.6130, -0.9360, -226.0940, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249193, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -327.0000, -1.0000, -315.0000, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249194, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 239.4210, -19.6590, 583.1220, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249195, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 58.8540, -2.6900, 56.4790, 23, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249196, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -233.9430, -0.4330, -283.5610, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249197, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -156.7300, -16.6530, -82.9720, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249198, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 345.7520, -19.4600, 397.3210, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249199, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -132.4600, -17.4630, 396.8220, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249200, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 230.8490, -26.0810, 394.2680, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249201, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -42.0760, -16.2460, 393.7770, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249202, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 241.9340, -21.2350, 454.6720, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249203, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 100.0000, -1.0000, -281.0000, 39, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249204, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 167.4640, -4.0390, 16.2780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249205, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 317.4830, -20.5570, 598.1660, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249206, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 162.3730, -1.0260, -49.0430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249207, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 27.4590, -18.4350, 328.8470, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249208, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -165.3370, -16.6960, -115.1570, 106, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249209, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -144.4520, -2.6080, -406.2630, 101, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249210, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 53.1590, -24.5400, 554.6520, 93, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249211, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -84.2650, -21.1140, 141.7360, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249212, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -323.2370, -21.4250, 209.8370, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249213, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 198.5750, -20.3990, 474.4790, 113, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249214, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 63.4370, -5.9600, 90.0560, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249215, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -287.0000, 4.0000, -449.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249216, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -49.5580, -16.7820, 8.4250, 125, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249217, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -24.0000, -2.0000, -360.0000, 12, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249218, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 315.7830, -17.7550, 411.5390, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249219, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 77.5090, -20.7190, 434.7570, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249220, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 199.0470, -21.1350, 585.5330, 71, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249221, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -40.0230, -12.6070, 242.7780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249222, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 104.0000, -1.0000, -359.0000, 128, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249223, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 92.3050, -14.9060, 202.5050, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249224, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 278.6200, -16.6190, 200.4470, 57, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249225, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 152.4800, -4.0720, 42.5750, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249226, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 81.6900, -0.0340, -5.7330, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249227, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -95.3840, -17.3450, 299.2810, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249228, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -226.0000, -16.0000, 419.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249229, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -94.2680, -5.3870, -123.8330, 103, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249230, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 145.3990, 2.7980, -440.4880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249231, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -69.5290, -15.9340, 366.4590, 58, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249232, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 86.0000, -1.0000, -191.0000, 114, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249233, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -245.0000, -1.0000, -396.0000, 59, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249234, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 57.0000, -18.0000, 260.0000, 92, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249235, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 139.1540, -21.4180, 505.4160, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249236, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 22.0270, -21.2850, 496.9590, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249237, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -160.8010, -4.9530, -212.0110, 50, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249238, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -351.0000, 4.0000, -446.0000, 52, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249239, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -81.7360, -20.2600, 79.7430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249240, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 236.6740, -22.8240, 628.3390, 11, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249241, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -371.5270, -29.3660, 432.0020, 100, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249242, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -49.0680, -4.6170, -225.6050, 79, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249243, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -124.6770, -4.7170, -168.9710, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249244, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 205.9940, -5.3470, 45.9300, 43, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249245, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 64.5300, -9.0160, 142.1340, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249246, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 36.7160, -1.1620, 18.9530, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249247, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 353.0000, -4.0000, 5.0000, 82, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249248, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -369.7810, -17.1200, 334.3550, 4, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249249, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -265.0000, -1.0000, -318.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249250, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 104.0000, -1.0000, -312.0000, 21, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249251, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 14.5760, -17.8920, 420.8900, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249252, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -241.8550, -31.4630, 547.1050, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249253, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -4.7030, -13.4000, 270.7520, 124, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249254, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 42.3760, -0.5260, -183.9440, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249255, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 98.1260, 2.8250, -438.1030, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249256, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -259.0000, 8.0000, -481.0000, 89, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249257, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -203.5810, -25.2600, 495.9070, 70, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249258, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 271.0000, -21.0000, 296.0000, 40, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249259, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -10.9680, -5.5290, 22.8950, 20, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249260, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 212.0000, -28.0000, 282.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249261, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 26.5550, -7.9430, 106.3580, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249262, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 190.0000, -34.0000, 384.0000, 122, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249263, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 46.0000, -0.4250, -88.0000, 92, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249264, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -369.0000, 4.0000, -388.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249265, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 158.0000, -40.0000, 318.0000, 91, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249266, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 338.4550, -5.6530, 118.8780, 110, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249267, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 317.4140, -16.6740, 365.2120, 34, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249268, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 47.6580, -0.9440, -274.8800, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249269, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 22.5970, -1.5000, -341.1770, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249270, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -90.9830, -5.2300, -215.5460, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249271, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 190.0000, -24.0000, 248.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249272, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 269.4680, -17.9780, 237.4570, 91, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249273, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -320.0000, -18.0000, 262.0000, 47, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249274, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 284.2230, -5.1160, 65.7910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249275, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -297.4080, -17.0630, 353.9750, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249276, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 300.0000, -5.0000, 5.0000, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249277, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 123.0000, -32.0000, 282.0000, 93, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249278, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 281.7500, -22.5480, 380.8520, 34, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17249279, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -21.1890, -2.7000, -391.3330, 127, NULL, NULL);

-- East Sarutabaruta (Zone 116)
INSERT INTO `mob_groups` VALUES (200, 3924, 116, 'Tiny_Mandragora', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_groups` VALUES (201, 583, 116, 'Bumblebee', 0, 0, 0, 0, 0, 0, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253226, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -359.9960, -0.3360, -156.4950, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253227, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 473.0230, 9.4900, -142.3420, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253228, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 34.9890, -7.0220, 221.6480, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253229, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -357.9830, -21.1520, 494.5850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253230, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 260.4070, -25.4900, 557.0290, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253231, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 221.9070, -8.4570, -3.4210, 52, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253232, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -16.7780, -24.8580, 476.0260, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253233, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -92.1370, -5.0720, -454.4610, 26, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253234, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 267.5120, -4.5090, -224.2680, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253235, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -108.0000, -1.0000, -238.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253236, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 347.7380, -13.0140, 119.8940, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253237, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -96.1310, -2.9980, 113.0050, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253238, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -193.0450, -12.7520, 435.0590, 38, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253239, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 361.2480, -17.1380, -336.7740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253240, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 354.2250, -12.5200, -42.9220, 64, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253241, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 101.6280, -24.2830, 389.8140, 56, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253242, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 271.1760, -21.2340, 433.3140, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253243, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -76.2170, -11.1910, 252.7750, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253244, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -19.2720, 0.9990, -167.5010, 42, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253245, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -117.5280, -20.5860, 516.9910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253246, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -109.8960, -4.9470, -353.4160, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253247, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -201.4000, -20.7690, 567.0290, 1, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253248, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 22.2120, -5.2690, -5.4630, 28, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253249, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -169.1980, -4.7900, -31.9710, 18, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253250, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -143.0500, -2.5790, 191.4000, 118, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253251, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 297.1190, -9.4140, 46.4800, 34, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253252, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -154.1490, -20.4810, 354.4320, 89, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253253, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -271.2510, -11.7360, 399.3820, 26, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253254, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -89.2170, -21.2070, 437.3120, 96, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253255, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -251.4490, -16.8070, 503.4360, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253256, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 205.8620, -20.6450, 478.4020, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253257, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 152.3490, -4.2970, -265.9320, 85, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253258, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -82.0000, -4.0000, -530.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253259, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -164.0000, -2.0000, -173.0000, 118, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253260, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -251.0000, -4.0000, -32.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253261, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 165.5740, -4.1410, -48.0670, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253262, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -49.7700, -33.8260, 680.0620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253263, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 30.9190, -3.7540, -82.1650, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253264, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -38.7440, -1.9750, -227.3880, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253265, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 246.4990, -7.0310, 260.8070, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253266, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 154.4830, -20.0770, 309.3280, 109, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253267, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 201.6360, -11.6950, 212.5810, 79, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253268, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 300.5690, -25.5650, 514.7590, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253269, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 142.3440, -4.9680, -322.9740, 13, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253270, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -115.5300, -4.6940, -75.9700, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253271, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 389.5780, 2.8920, -113.9490, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253272, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -154.8570, -1.4720, -115.2230, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253273, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -303.5680, -2.8580, -197.4110, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253274, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -138.4500, -6.5500, 243.5500, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253275, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 83.3680, -8.7400, 203.5380, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253276, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -36.9220, -4.6470, -477.2830, 121, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253277, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 158.2690, -0.8000, -155.5630, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253278, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 306.7840, -5.1420, -253.1160, 61, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253279, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 354.1850, -4.5900, 244.2050, 120, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253280, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -74.7240, -36.5680, 724.0620, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253281, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 423.9780, 5.1610, -146.6800, 29, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253282, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 296.4750, -12.1080, 100.3940, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253283, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 313.3950, -9.1780, 4.1710, 9, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253284, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -187.7300, -5.2570, -72.3980, 58, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253285, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 132.5480, -10.4680, 196.3560, 22, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253286, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -20.4800, 1.5000, -33.6100, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253287, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 358.0180, -12.7390, -0.4110, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253288, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 253.4590, -9.4860, 25.1470, 57, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253289, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 367.9610, -12.8940, 83.4540, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253290, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -47.0000, 3.0000, -641.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253291, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 105.4720, -4.6200, -88.4000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253292, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 298.5610, -13.5830, 143.8580, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253293, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 261.4430, -19.9700, 470.2990, 82, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253294, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -270.9960, -15.7350, 437.4920, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253295, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 18.8970, -7.0000, 256.1000, 125, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253296, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -66.4980, -0.8950, -156.4090, 102, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253297, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 389.3810, -5.0020, -280.8180, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253298, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 174.4810, -7.1070, 260.8920, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253299, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, 114.6990, -12.8460, 112.8210, 39, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253300, 0, 'Tiny_Mandragora', 'Tiny Mandragora', 200, 1, 1, -81.2130, -5.1430, -376.0590, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253301, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -29.8630, -37.4290, 741.2910, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253302, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -81.3050, 7.7090, -697.3270, 8, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253303, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 76.7280, -5.4310, -297.6610, 83, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253304, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 437.1120, -3.0470, 296.7050, 101, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253305, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 298.6570, -17.4530, -481.9180, 123, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253306, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -62.2770, -1.5170, -46.6080, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253307, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -205.4880, -8.7290, 282.1690, 79, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253308, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 212.5270, -20.4670, 326.2150, 73, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253309, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -238.0930, -22.9990, 656.6090, 126, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253310, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -230.2150, -4.7490, 37.3430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253311, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 81.0150, -0.8880, -120.8490, 126, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253312, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -212.0800, -3.4460, -115.1720, 106, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253313, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 173.0810, -12.8690, 160.9850, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253314, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 66.9050, -28.2260, 585.9970, 32, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253315, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 38.7000, -4.1970, -428.1400, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253316, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 94.2690, -11.6190, 62.9940, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253317, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 308.3300, -2.5000, 260.0100, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253318, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 195.2090, -0.7750, -122.7740, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253319, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 201.8680, -16.7200, -431.9860, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253320, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -46.6170, -0.6770, -599.7550, 3, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253321, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 227.8250, -16.9780, -317.4670, 82, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253322, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 78.1150, -24.6010, 484.0430, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253323, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 337.3540, 5.1060, -134.2510, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253324, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -250.0680, -0.8170, -197.6320, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253325, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 140.8070, -6.8730, 245.6320, 16, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253326, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 290.5830, -16.8890, -390.8650, 117, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253327, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 260.8500, -13.4550, 131.2180, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253328, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 112.8170, -0.8260, -199.8200, 1, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253329, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 95.5740, -5.3720, -40.8780, 12, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253330, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -25.0450, -11.7950, 168.6070, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253331, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -98.0370, 1.0050, 22.8140, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253332, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 358.6000, -5.5380, -259.9830, 237, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253333, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -79.4590, -0.5030, -120.8960, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253334, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 204.6190, -20.7180, 401.8180, 41, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253335, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 262.7970, 5.0000, -97.0210, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253336, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 367.9800, -7.4120, 304.2590, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253337, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 109.2700, -12.8990, 159.1370, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253338, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -102.0000, 2.0000, -630.0000, 35, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253339, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 56.0990, -5.2210, -368.4770, 48, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253340, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -37.3500, -3.6160, -426.7720, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253341, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 39.7230, -26.4080, 532.7490, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253342, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 224.2580, -17.8580, -486.2560, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253343, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -222.7890, -7.0350, 367.0370, 68, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253344, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -107.1100, -9.3640, 320.7610, 49, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253345, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -81.6550, -6.5600, 176.8030, 77, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253346, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 220.8630, -5.7980, -262.3270, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253347, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -16.4600, 0.9790, -110.3800, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253348, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -65.3740, -0.9160, -273.2780, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253349, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 145.9100, 1.5000, -105.1600, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253350, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -114.0040, -0.7960, -162.5060, 54, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253351, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 78.4480, -12.5830, 119.6310, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253352, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 239.5660, -17.0000, -400.8120, 199, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253353, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 214.0570, -3.1100, -51.4400, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253354, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 104.2140, -4.3130, 6.5090, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253355, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 84.4420, -24.4440, 436.4180, 97, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253356, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -42.9650, -9.4820, 218.9650, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253357, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 24.6590, -25.3600, 454.3970, 3, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253358, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 65.6220, -0.8530, -163.0000, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253359, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 301.6560, 2.4390, -75.4260, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253360, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -76.0760, -21.3290, 502.8990, 52, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253361, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -135.7470, -21.2290, 477.9880, 16, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253362, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 164.6680, -23.4710, 386.9900, 1, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253363, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -218.8600, -6.5000, 324.9300, 0, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253364, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 206.8250, -9.5480, 284.9670, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253365, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -78.6630, -3.8300, -415.5160, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253366, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -119.4240, -4.3520, -314.6410, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253367, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -342.5700, -2.5890, -198.5610, 30, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253368, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -87.1840, 0.8780, -17.7370, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253369, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -163.1270, -8.6330, 272.5820, 17, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253370, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -221.2050, -23.0490, 622.5970, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253371, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 225.1550, 1.0000, -100.3360, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253372, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 222.6360, -21.3140, 369.4310, 102, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253373, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 2.2710, -4.7650, -434.0730, 127, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253374, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, 383.9760, -2.9990, 271.1310, 29, NULL, NULL);
INSERT INTO `mob_spawn_points` VALUES (17253375, 0, 'Bumblebee', 'Bumblebee', 201, 1, 1, -215.2510, -10.6380, 463.8710, 127, NULL, NULL);
