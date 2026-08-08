-- Module for Pheonix only changes
-- Changes in here should only be if LSB is correct and we need to change it

-- NPC Lists
-- Turn back on QMs for Kings
UPDATE `npc_list` SET `content_tag` = NULL WHERE `npcid` = 17408033 AND `name` = 'qm0'; -- Dragons Aery
UPDATE `npc_list` SET `content_tag` = NULL WHERE `npcid` = 17301543 AND `name` = 'qm0'; -- Valley of Sorrows
UPDATE `npc_list` SET `content_tag` = NULL WHERE `npcid` = 17297459 AND `name` = 'qm2'; -- Behemoths Dominion

-- Retags the expansion-specific "Tales' Beginning" NPCs from TVR to the
-- expansion whose storyline they actually start, so that players who skip
-- cutscenes can use them. This is because we have decided not to remove
-- the cutscene skip options from the game, and we want to avoid players
-- being unable to use these NPCs if they skip the cutscenes.
UPDATE `npc_list` SET `content_tag` = 'COP'  WHERE `npcid` = 17531245 AND `name` = 'Tales_Beginning'; -- Lower Delkfutt's Tower (Zone 184), Chains of Promathia
UPDATE `npc_list` SET `content_tag` = 'ACP'  WHERE `npcid` = 17781072 AND `name` = 'Tales_Beginning'; -- Lower Jeuno (Zone 245), A Crystalline Prophecy
UPDATE `npc_list` SET `content_tag` = 'ROTZ' WHERE `npcid` = 17809554 AND `name` = 'Tales_Beginning'; -- Norg (Zone 252), Rise of the Zilart
UPDATE `npc_list` SET `content_tag` = 'ASA'  WHERE `npcid` = 17756512 AND `name` = 'Tales_Beginning'; -- Windurst Walls (Zone 239), A Shantotto Ascension

-- Enable Linkshell Concierge NPCs
UPDATE `npc_list` SET `content_tag` = NULL WHERE `name` = 'Linkshell_Concierge';
