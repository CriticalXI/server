-----------------------------------
-- Pernicious Presents: Twinkling Treant world event
-----------------------------------

-- Setup Twinkling Treant mob pool and group for Dynamic Entity usage
DELETE FROM `mob_pools` WHERE `poolid` = 31000;
INSERT INTO `mob_pools` VALUES (31000,'Twinkling_Treant','Twinkling_Treant',366,0x0000850100000000000000000000000000000000,1,4,7,240,100,0,0,0,0,2,0,0,0,131,0,0,2,0,0,245,245,3,43);

DELETE FROM `mob_groups` WHERE `zoneid` = 100 AND `groupid` = 200;
INSERT INTO `mob_groups` VALUES (200,31000,100,'Twinkling_Treant',0,128,0,0,0,0,NULL);

-- Setup Arbor Storm mob skill for Twinkling Treants
DELETE FROM `mob_skills` WHERE `mob_skill_id` = 1026;
INSERT INTO `mob_skills` VALUES (1026,727,'arbor_storm',1,0.0,10.0,2000,1500,4,0,0,2,0,0,0);
