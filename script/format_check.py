# coding=utf-8
# Currently only check icons
from pathlib import Path
import os
import re

root_path = Path("../")
translation_en_path = root_path / Path("cn/localisation/english/")
en_path = root_path / Path("en/localisation/english/")
diff_path = root_path / Path("diff/")

icon_pattern = r'£(?P<name>[a-zA-Z0-9_\|$]*?)(?P<end_char> |£|[^a-zA-Z0-9_\|$])'
valid_icon_list = ['physics', 'opinion', 'fleet_status|2', 'military_power', 'minerals', 'ship_stats_hitpoints',
                   'ship_stats_armor', 'ship_stats_shield', 'military_ship', 'fleet_template_size', 'energy', 'food',
                   'unity', 'influence', 'society', 'engineering', 'pops', 'building', 'blocker', 'sr_zro',
                   'sr_dark_matter', 'sr_living_metal', 'pop', 'happiness', 'alloys', 'gamepad_a', 'gamepad_b',
                   'gamepad_x', 'gamepad_y', 'gamepad_start', 'gamepad_lt', 'gamepad_rt', 'gamepad_rs', 'system',
                   'planet', 'trigger_no', 'trigger_yes', '$ICON$', 'amenities', 'job', 'job_servant',
                   'amenities_no_happiness', 'trade_value', 'ship_stats_special', 'military_power_boss', 'science_ship',
                   'construction_ship', 'colony_ship', 'army_ship', 'army_power', 'pop_modifier', 'def', '$RESOURCE$',
                   'mod_faction_approval', 'shift', 'resource_time', '$KEY$', 'ship_modifier', 'navy_size', 'science',
                   'economy', 'ctrl', 'space', 'kp_plus', 'kp_minus', 'alt', 'm', 'e', 'time', 'planetsize', 'escape',
                   'anomaly_level', 'ship_stats_piracy_supression', 'ship_stats_build_cost', 'ship_stats_build_time',
                   'ship_stats_maintenance', 'ship_stats_power', 'ship_stats_speed', 'ship_stats_evasion',
                   'ship_stats_damage', 'consumer_goods', 'pop_cat_ruler', 'pop_cat_specialist', 'pop_cat_worker',
                   'pop_cat_slave', 'job_entertainer', '$CURRENCY_KEY$', 'slavery', 'unemployment', 'job_researcher',
                   'housing', 'job_farmer', 'job_soldier', 'job_administrator', 'job_high_priest', 'job_priest',
                   'job_noble', 'job_enforcer', 'job_head_researcher', 'job_merchant', 'leader_skill|$LEVEL$',
                   'job_miner', 'stability', 'district', 'crime', 'job_patrol_drone', 'trade_protection',
                   'job_maintenance_drone', 'political_power', 'repair', 'upgrade', 'decision', 'job_roboticist',
                   'engineering_research', 'job_mining_drone', 'mod_job_mining_drone_add', 'job_warrior_drone',
                   'mod_country_naval_cap_add', 'defense_army', 'mod_job_warrior_drone_add', 'job_crystal_mining_drone',
                   'rare_crystals', 'mod_job_crystal_mining_drone_add', 'job_mote_harvesting_drone', 'volatile_motes',
                   'mod_job_mote_harvesting_drone_add', 'job_gas_extraction_drone', 'exotic_gases',
                   'mod_job_gas_extraction_drone_add', 'job_agri_drone', 'mod_job_agri_drone_add',
                   'job_technician_drone', 'mod_job_technician_drone_add', 'job_spawning_drone',
                   'mod_planet_amenities_no_happiness_add', 'mod_pop_growth_speed', 'mod_job_spawning_drone_add',
                   'job_replicator', 'mod_job_replicator_add', 'job_synapse_drone', 'mod_job_synapse_drone_add',
                   'job_coordinator', 'mod_job_coordinator_add', 'mod_job_maintenance_drone_add', 'job_brain_drone',
                   'mod_job_brain_Drone_add', 'job_calculator', 'mod_job_calculator_add', 'job_fabricator',
                   'mod_job_fabricator_add', 'job_artisan_drone', 'mod_job_artisan_drone_add', 'job_alloy_drone',
                   'mod_job_alloy_drone_add', 'mod_job_patrol_drone_add', 'job_chemist_drone',
                   'mod_job_chemist_drone_add', 'job_translucer_drone', 'mod_job_translucer_drone_add',
                   'job_gas_refiner_drone', 'mod_job_gas_refiner_drone_add', 'job_colonist', 'mod_planet_amenities_add',
                   'mod_job_colonist_add', 'mod_job_miner_add', 'job_crystal_miner', 'mod_job_crystal_miner_add',
                   'job_mote_harvester', 'mod_job_mote_harvester_add', 'job_gas_extractor', 'mod_job_gas_extractor_add',
                   'mod_job_farmer_add', 'job_technician', 'mod_job_technician_add', 'job_clerk', 'mod_trade_value_add',
                   'mod_job_clerk_add', 'job_preacher', 'mod_job_preacher_add', 'job_foundry', 'mod_job_foundry_add',
                   'mod_job_enforcer_add', 'job_slave_overseer', 'mod_job_slave_overseer_add', 'job_telepath',
                   'mod_job_telepath_add', 'mod_job_soldier_add', 'job_artisan', 'mod_job_artisan_add',
                   'mod_job_entertainer_add', 'job_healthcare', 'mod_job_healthcare_add', 'job_culture_worker',
                   'mod_job_culture_worker_add', 'mod_job_head_researcher_add', 'mod_job_researcher_add',
                   'mod_job_high_priest_add', 'mod_job_priest_add', 'job_chemist', 'mod_job_chemist_add',
                   'job_translucer', 'mod_job_translucer_add', 'job_gas_refiner', 'mod_job_gas_refiner_add',
                   'mod_job_roboticist_add', 'job_manager', 'mod_job_manager_add', 'mod_job_administrator_add',
                   'mod_planet_stability_add', 'mod_job_noble_add', 'mod_job_merchant_add', 'job_executive',
                   'mod_job_executive_add', 'mod_job_bio_trophy_add', 'mod_job_criminal_add',
                   'mod_job_deviant_drone_add', 'mod_job_corrupt_drone_add', 'mod_job_underground_trade_worker_add',
                   'job_fe_acolyte_farm', 'job_fe_acolyte_mine', 'job_fe_acolyte_generator', 'job_fe_acolyte_artisan',
                   'job_livestock', 'society_research', 'physics_research', '$RESOURCE_KEY$', '$AREA_KEY$',
                   'mod_pop_amenities_usage_mult', 'mod_pop_amenities_usage_no_happiness_mult']


def main(mode: str):
    # TODO use logging
    if mode == "diff":
        files_path = diff_path
    elif mode == "init":
        files_path = en_path
    elif mode == "trans_en":
        files_path = translation_en_path
    else:
        files_path = translation_en_path
    for file_name in os.listdir(files_path):
        with (files_path / file_name).open(mode = 'r', encoding = 'utf8') as file:
            print(file_name)
            line_number = 0
            for line in file:
                line_number += 1
                if files_path == diff_path:  # only check CHANGE and CN2
                    if not (line.startswith("CHANGE") or line.startswith("CN2")):
                        continue
                icons = re.finditer(icon_pattern, line)
                for icon in icons:
                    # generate valid icons
                    # if not icon.group('name') in valid_icon_list:
                    #     valid_icon_list.append(icon.group('name'))
                    if not icon.group('name') in valid_icon_list:
                        print(line_number, icon, "Unknown icon")
                    elif not icon.group('end_char') == '£':
                        print(line_number, icon, "Miss ending character")
                    # if icon.group('after_char') is not ' ':
                    #     print(line_number, icon)


if __name__ == "__main__":
    main("diff")
