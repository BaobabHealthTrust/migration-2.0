INSERT INTO patients (given_name, middle_name, family_name, gender, dob, dob_estimated, dead, traditional_authority, current_address, landmark, cellphone_number, home_phone_number, office_phone_number, occupation, nat_id, art_number, pre_art_number, tb_number, legacy_id, legacy_id2, legacy_id3, new_nat_id, prev_art_number, filing_number, archived_filing_number, voided, void_reason, date_voided, voided_by, date_created, creator) VALUES ('Lucious', NULL, 'Chiwaya', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186247', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-10-29', 1), ('Mary', NULL, 'Mjojo', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186256', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-10-29', 1), ('Wilson', NULL, 'Mbela', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186265', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-10-29', 1), ('Ginny ', NULL, 'Ngwangwa', 'Female', '1976-03-25', 'true', 0, NULL, NULL, NULL, NULL, 'Unknown', NULL, 'Student', 'P168900745429', NULL, NULL, 'ZA 1115 09', NULL, NULL, NULL, '2KPYYY', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Miriam', NULL, 'Turaliki', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186283', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Mary', NULL, 'Vayiye', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186292', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Tusimenye', NULL, 'Muakasungula', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186309', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Ellen', NULL, 'Lazaro', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186318', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Biliat', NULL, 'Kazembe', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186327', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-01', 1), ('Francis', NULL, 'Tanaposi', 'Female', '2004-07-01', 'true', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'P168900186336', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2004-11-02', 1);
INSERT INTO first_visit_encounters (visit_encounter_id, patient_id, agrees_to_follow_up, date_of_hiv_pos_test, date_of_hiv_pos_test_estimated, location_of_hiv_pos_test, arv_number_at_that_site, location_of_art_initiation, taken_arvs_in_last_two_months, taken_arvs_in_last_two_weeks, has_transfer_letter, site_transferred_from, date_of_art_initiation, ever_registered_at_art, ever_received_arv, last_arv_regimen, date_last_arv_taken, date_last_arv_taken_estimated, voided, void_reason, date_voided, voided_by, date_created, creator) VALUES (2256, 4, 'Yes', NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-08-01 23:32:54 UTC', 1), (2257, 4, 'Yes', NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-08-01 23:37:05 UTC', 1), (2258, 4, 'Yes', '2010-07-19 00:00:00 UTC', 'false', 'Cobbe Barracks Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-08-20 14:58:07 UTC', 476), (2259, 4, 'No', '2008-11-11 00:00:00 UTC', 'false', 'Zomba Central Hospital', '1991.0', 'Queen Elizabeth Central Hospital', NULL, 'Yes', 'Yes', 'Queen Elizabeth Central Hospital', '2008-11-11 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-08-26 12:39:56 UTC', 456), (2259, 4, 'Yes', '2008-09-16 00:00:00 UTC', 'false', 'Zomba Central Hospital', '1991.0', 'Ndirande Urban Health Centre', NULL, 'Yes', 'Yes', 'Ndirande Urban Health Centre', '2008-11-11 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-08-26 15:27:53 UTC', 461), (2260, 4, 'Yes', '2009-10-23 00:00:00 UTC', 'false', 'Balaka Health Area', '2443.0', 'Balaka District Hospital', NULL, 'Yes', 'Yes', 'Balaka District Health Office', '2009-10-23 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-09-02 11:37:47 UTC', 456), (2261, 4, 'Yes', '2010-08-23 00:00:00 UTC', 'false', 'Pirimiti Health Centre', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-09-08 11:58:01 UTC', 452), (2262, 4, 'Yes', '2003-09-05 00:00:00 UTC', 'false', 'Zomba Central Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-09-16 10:57:07 UTC', 438), (2262, 4, 'Yes', '2010-08-10 00:00:00 UTC', 'false', 'Zomba Central Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-09-16 14:49:28 UTC', 461), (2263, 4, 'Yes', '2009-12-10 00:00:00 UTC', 'false', 'Door to door', '721.0', 'Matawale Urban Health Centre', NULL, 'Yes', 'No', 'Matawale Urban Health Centre', '2009-06-10 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-10-22 15:23:53 UTC', 438), (2264, 4, 'Yes', '2008-08-16 00:00:00 UTC', 'false', 'Zomba Central Hospital', '10225.0', 'Zomba Central Hospital', NULL, 'Yes', 'No', 'Unknown', '2009-06-10 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-11-19 11:43:46 UTC', 496), (2265, 4, 'Yes', '2010-07-19 00:00:00 UTC', 'false', 'Cobbe Barracks Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-11-22 10:05:03 UTC', 455), (2265, 4, 'Yes', '2010-07-19 00:00:00 UTC', 'false', 'Other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-11-22 10:18:47 UTC', 478), (2266, 4, 'Yes', '2010-07-26 00:00:00 UTC', 'false', 'Zomba Central Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-11-25 09:38:51 UTC', 427), (2267, 4, NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-11-30 08:49:49 UTC', 456), (2268, 4, NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-12-10 09:52:52 UTC', 461), (2269, 4, 'Yes', '2010-07-19 00:00:00 UTC', 'false', 'Zomba Central Hospital', '14215.0', 'Zomba Central Hospital', NULL, 'Yes', 'Unknown', 'Unknown', '2010-09-16 00:00:00 UTC', 'Yes', 'Yes', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2010-12-24 11:19:04 UTC', 496), (2270, 4, NULL, NULL, 'false', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2011-02-03 09:48:52 UTC', 447), (2271, 4, 'Yes', NULL, 'false', 'Magomero Health Centre', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'No', 'No', NULL, NULL, NULL, 'false', NULL, NULL, NULL, '2011-02-07 16:01:35 UTC', 497);
INSERT INTO hiv_reception_encounters (visit_encounter_id, patient_id, patient_present, guardian_present, date_created, creator) VALUES (2305, 4, 'Yes', 'No', '2010-08-17 16:06:11 UTC', 428), (2258, 4, 'Yes', 'No', '2010-08-20 14:56:58 UTC', 476), (2259, 4, 'Yes', 'No', '2010-08-26 12:34:56 UTC', 456), (2259, 4, 'Yes', 'Yes', '2010-08-26 15:24:52 UTC', 461), (2260, 4, 'Yes', 'Yes', '2010-09-02 11:35:55 UTC', 456), (2261, 4, 'Yes', 'Yes', '2010-09-08 11:57:21 UTC', 452), (2262, 4, 'Yes', 'No', '2010-09-16 10:55:04 UTC', 438), (2262, 4, 'Yes', 'No', '2010-09-16 14:48:37 UTC', 461), (2262, 4, 'Yes', 'Yes', '2010-09-16 16:28:16 UTC', 475), (2354, 4, 'Yes', 'No', '2010-09-24 11:44:02 UTC', 456), (2306, 4, 'Yes', 'No', '2010-10-07 10:31:23 UTC', 456), (2307, 4, 'Yes', 'No', '2010-10-11 10:01:51 UTC', 487), (2308, 4, 'Yes', 'No', '2010-10-12 11:12:18 UTC', 478), (2309, 4, 'Yes', 'No', '2010-10-12 11:13:01 UTC', 478), (2310, 4, 'Yes', 'No', '2010-10-12 11:14:54 UTC', 478), (2311, 4, 'Yes', 'No', '2010-10-12 11:16:03 UTC', 478), (2312, 4, 'Yes', 'No', '2010-10-12 11:16:33 UTC', 478), (2263, 4, 'Yes', 'No', '2010-10-22 12:13:59 UTC', 461), (2263, 4, 'Yes', 'No', '2010-10-22 15:18:17 UTC', 438), (2313, 4, 'Yes', 'No', '2010-11-15 10:24:31 UTC', 453), (2264, 4, 'Yes', 'No', '2010-11-19 11:37:09 UTC', 496), (2265, 4, 'No', 'Yes', '2010-11-22 09:36:20 UTC', 460), (2265, 4, 'Yes', 'Yes', '2010-11-22 09:41:47 UTC', 460), (2314, 4, 'Yes', 'No', '2010-11-25 09:40:48 UTC', 427), (2315, 4, 'Yes', 'No', '2010-11-25 09:41:49 UTC', 427), (2267, 4, NULL, NULL, '2010-11-30 08:48:41 UTC', 456), (2316, 4, 'Yes', 'No', '2010-12-06 09:15:15 UTC', 455), (2268, 4, NULL, NULL, '2010-12-10 09:52:18 UTC', 461), (2317, 4, 'Yes', 'No', '2010-12-13 11:34:35 UTC', 456), (2318, 4, 'Yes', 'No', '2010-12-17 10:50:34 UTC', 455), (2269, 4, 'No', 'Yes', '2010-12-24 09:47:02 UTC', 455), (2269, 4, 'Yes', 'No', '2010-12-24 09:54:28 UTC', 456), (2263, 4, 'Missing', 'Yes', '2010-12-24 10:19:36 UTC', 520), (2327, 4, 'Yes', 'No', '2010-12-28 08:43:21 UTC', 456), (2319, 4, 'Yes', 'No', '2011-01-05 12:08:50 UTC', 456), (2320, 4, NULL, NULL, '2011-01-10 10:16:10 UTC', 456), (2320, 4, NULL, NULL, '2011-01-10 13:14:22 UTC', 455), (2321, 4, NULL, NULL, '2011-01-10 14:51:06 UTC', 497), (2262, 4, 'Yes', 'Yes', '2011-01-10 16:42:56 UTC', 497), (2322, 4, 'Yes', 'No', '2011-01-21 12:10:05 UTC', 461), (2322, 4, 'Yes', 'No', '2011-01-21 12:10:24 UTC', 461), (2322, 4, 'Yes', 'Yes', '2011-01-21 12:34:11 UTC', 455), (2323, 4, NULL, NULL, '2011-01-25 12:19:18 UTC', 455), (2324, 4, 'Yes', 'No', '2011-01-26 11:20:21 UTC', 456), (2325, 4, NULL, NULL, '2011-01-31 15:55:57 UTC', 497), (2326, 4, NULL, NULL, '2011-01-31 15:56:51 UTC', 497), (2267, 4, NULL, NULL, '2011-01-31 15:57:35 UTC', 497), (2327, 4, 'Yes', 'No', '2011-01-31 15:58:09 UTC', 497), (2328, 4, NULL, NULL, '2011-01-31 16:00:36 UTC', 497), (2329, 4, NULL, NULL, '2011-01-31 16:01:45 UTC', 497), (2330, 4, NULL, NULL, '2011-01-31 16:43:49 UTC', 497), (2270, 4, NULL, NULL, '2011-02-03 09:45:53 UTC', 447), (2270, 4, NULL, NULL, '2011-02-03 10:08:39 UTC', 478), (2270, 4, NULL, NULL, '2011-02-03 10:09:05 UTC', 478), (2270, 4, NULL, NULL, '2011-02-03 10:12:01 UTC', 478), (2270, 4, NULL, NULL, '2011-02-03 10:12:53 UTC', 478), (2270, 4, 'Yes', 'No', '2011-02-03 10:14:03 UTC', 478), (2331, 4, 'Yes', 'No', '2011-02-07 11:54:10 UTC', 456), (2271, 4, 'Yes', 'Yes', '2011-02-07 16:03:44 UTC', 497), (2332, 4, NULL, NULL, '2011-02-07 16:05:08 UTC', 497), (2280, 4, 'Yes', 'No', '2011-02-07 16:06:55 UTC', 497), (2290, 4, 'Yes', 'No', '2011-02-07 16:07:41 UTC', 497), (2294, 4, 'Yes', 'No', '2011-02-07 16:08:36 UTC', 497), (2279, 4, 'Yes', 'No', '2011-02-07 16:09:49 UTC', 497), (2333, 4, 'Yes', 'No', '2011-02-07 16:11:00 UTC', 497), (2334, 4, 'Yes', 'No', '2011-02-18 10:40:08 UTC', 461), (2335, 4, NULL, NULL, '2011-02-23 08:49:24 UTC', 461), (2336, 4, 'Yes', 'No', '2011-03-07 09:54:50 UTC', 456), (2337, 4, 'Yes', 'No', '2011-03-08 13:33:42 UTC', 478), (2338, 4, NULL, NULL, '2011-03-10 12:52:40 UTC', 461), (2339, 4, 'Yes', 'No', '2011-03-18 11:10:20 UTC', 497), (2339, 4, 'Yes', 'No', '2011-03-18 13:58:41 UTC', 519), (2319, 4, 'Yes', 'No', '2011-04-05 14:55:45 UTC', 427), (2340, 4, 'Yes', 'No', '2011-04-05 14:56:29 UTC', 427), (2281, 4, NULL, NULL, '2011-04-05 15:30:46 UTC', 444), (2275, 4, 'Yes', 'Yes', '2011-04-05 15:35:11 UTC', 444), (2303, 4, 'No', 'Yes', '2011-04-05 15:36:52 UTC', 444), (2281, 4, 'Yes', 'No', '2011-04-05 15:38:23 UTC', 444), (2293, 4, 'Yes', 'Yes', '2011-04-05 15:43:40 UTC', 444), (2285, 4, 'Yes', 'Yes', '2011-04-05 15:46:03 UTC', 444), (2302, 4, 'Yes', 'Yes', '2011-04-05 15:47:58 UTC', 444), (2341, 4, 'Yes', 'Yes', '2011-04-05 15:48:50 UTC', 444), (2342, 4, 'Yes', 'Yes', '2011-04-05 15:49:32 UTC', 444), (2343, 4, NULL, NULL, '2011-04-05 15:51:53 UTC', 444), (2300, 4, 'Yes', 'Yes', '2011-04-05 15:53:38 UTC', 444), (2273, 4, 'Yes', 'Yes', '2011-04-05 15:55:55 UTC', 444), (2344, 4, 'Yes', 'Yes', '2011-04-05 15:57:10 UTC', 444), (2297, 4, 'Yes', 'Yes', '2011-04-05 15:57:52 UTC', 444), (2287, 4, 'Yes', 'Yes', '2011-04-05 15:59:18 UTC', 444), (2272, 4, 'Yes', 'Yes', '2011-04-05 16:00:47 UTC', 444), (2296, 4, 'Yes', 'Yes', '2011-04-05 16:01:47 UTC', 444), (2283, 4, 'Yes', 'No', '2011-04-05 16:03:15 UTC', 444), (2301, 4, 'Yes', 'No', '2011-04-05 16:04:04 UTC', 444), (2299, 4, 'Yes', 'No', '2011-04-05 16:05:01 UTC', 444), (2292, 4, 'Yes', 'No', '2011-04-05 16:05:42 UTC', 444), (2276, 4, 'Yes', 'No', '2011-04-05 16:06:19 UTC', 444), (2298, 4, 'Yes', 'No', '2011-04-05 16:06:56 UTC', 444), (2288, 4, 'Yes', 'No', '2011-04-05 16:09:14 UTC', 444), (2295, 4, 'Yes', 'No', '2011-04-05 16:11:31 UTC', 444), (2286, 4, 'Yes', 'No', '2011-04-05 16:13:21 UTC', 444), (2278, 4, 'Yes', 'No', '2011-04-05 16:14:31 UTC', 444), (2274, 4, 'Yes', 'No', '2011-04-05 16:15:42 UTC', 444), (2277, 4, 'Yes', 'No', '2011-04-05 16:16:52 UTC', 444), (2289, 4, 'Yes', 'No', '2011-04-05 16:17:41 UTC', 444), (2279, 4, 'Yes', 'No', '2011-04-05 16:18:43 UTC', 444), (2294, 4, 'Yes', 'No', '2011-04-05 16:19:53 UTC', 444), (2290, 4, 'Yes', 'No', '2011-04-05 16:20:31 UTC', 444), (2280, 4, 'Yes', 'No', '2011-04-05 16:21:43 UTC', 444), (2345, 4, NULL, NULL, '2011-04-06 09:26:25 UTC', 456), (2345, 4, 'Yes', 'No', '2011-04-11 08:46:04 UTC', 444), (2346, 4, NULL, NULL, '2011-04-21 09:49:03 UTC', 456), (2347, 4, 'Yes', 'No', '2011-05-05 10:28:26 UTC', 475), (2348, 4, NULL, NULL, '2011-05-12 11:19:51 UTC', 461), (2349, 4, 'Yes', 'No', '2011-05-17 11:39:38 UTC', 455), (2350, 4, 'Yes', 'No', '2011-06-21 14:14:08 UTC', 461), (2357, 4, 'Yes', 'No', '2011-06-22 12:11:32 UTC', 525), (2358, 4, 'Yes', 'No', '2011-06-23 08:52:03 UTC', 456), (2359, 4, 'Yes', 'No', '2011-07-04 10:01:20 UTC', 457), (2351, 4, 'Yes', 'No', '2011-07-26 10:46:31 UTC', 455), (2352, 4, 'Yes', 'No', '2011-08-04 09:48:55 UTC', 533), (2355, 4, 'Yes', 'No', '2011-09-23 11:58:23 UTC', 455), (2353, 4, 'Yes', 'No', '2011-10-26 13:49:05 UTC', 453), (2360, 4, 'Yes', 'No', '2012-05-31 08:45:15 UTC', 550);
INSERT INTO vitals_encounters (visit_encounter_id, patient_id, weight, height, bmi, date_created, creator) VALUES (2256, 4, '44.0', '158.0', '17.6253805479891', '2010-08-01 23:32:54 UTC', 1), (2257, 4, '45.0', NULL, '16.7311124330755', '2010-08-01 23:37:05 UTC', 1), (2356, 4, '19.0', '119.0', '13.4171315585058', '2010-08-02 00:17:16 UTC', 1), (2305, 4, '59.0', NULL, '21.9363474122546', '2010-08-17 16:06:11 UTC', 428), (2258, 4, '56.0', '156.0', '23.0111768573307', '2010-08-20 15:02:56 UTC', 476), (2259, 4, '60.0', NULL, '22.3081499107674', '2010-08-26 14:00:35 UTC', 453), (2261, 4, '45.0', '160.0', '17.578125', '2010-09-08 11:58:15 UTC', 452), (2262, 4, '59.3', '152.0', '25.6665512465374', '2010-09-16 10:59:10 UTC', 438), (2262, 4, '60.0', '157.0', '24.3417582863402', '2010-09-16 14:50:53 UTC', 461), (2262, 4, '60.0', NULL, '22.3081499107674', '2010-09-16 16:28:28 UTC', 475), (2306, 4, '32.0', NULL, '11.8976799524093', '2010-10-07 10:37:19 UTC', 475), (2307, 4, '45.0', NULL, '16.7311124330755', '2010-10-11 10:01:51 UTC', 487), (2309, 4, '54.0', NULL, '20.0773349196907', '2010-10-12 11:13:01 UTC', 478), (2310, 4, '63.5', NULL, '23.6094586555622', '2010-10-12 11:14:54 UTC', 478), (2311, 4, '64.0', NULL, '23.7953599048186', '2010-10-12 11:16:03 UTC', 478), (2312, 4, '64.0', NULL, '23.7953599048186', '2010-10-12 11:16:33 UTC', 478), (2263, 4, '60.0', NULL, '22.3081499107674', '2010-10-22 12:14:05 UTC', 461), (2263, 4, '56.0', '156.0', '23.0111768573307', '2010-10-22 15:27:06 UTC', 438), (2313, 4, '61.6', '153.0', '26.3146652996711', '2010-11-15 10:25:10 UTC', 453), (2265, 4, NULL, NULL, NULL, '2010-11-22 09:42:25 UTC', 460), (2314, 4, '40.0', '155.0', '16.6493236212279', '2010-11-25 09:40:48 UTC', 427), (2315, 4, '44.0', NULL, '16.3593099345628', '2010-11-25 09:41:49 UTC', 427), (2267, 4, NULL, NULL, NULL, '2010-11-30 08:50:35 UTC', 456), (2316, 4, '56.0', NULL, '20.8209399167162', '2010-12-06 09:15:22 UTC', 455), (2268, 4, NULL, NULL, NULL, '2010-12-10 09:53:15 UTC', 461), (2317, 4, '53.0', NULL, '19.7055324211779', '2010-12-13 11:34:45 UTC', 456), (2318, 4, '55.0', NULL, '20.4491374182034', '2010-12-17 10:50:41 UTC', 455), (2327, 4, '57.0', NULL, '21.192742415229', '2010-12-28 08:43:28 UTC', 456), (2319, 4, '56.0', NULL, '20.8209399167162', '2011-01-05 14:07:41 UTC', 460), (2320, 4, NULL, NULL, NULL, '2011-01-10 13:02:53 UTC', 448), (2320, 4, NULL, NULL, NULL, '2011-01-10 13:14:46 UTC', 455), (2323, 4, NULL, NULL, NULL, '2011-01-25 12:19:22 UTC', 455), (2324, 4, '60.0', NULL, '22.3081499107674', '2011-01-26 11:20:25 UTC', 456), (2267, 4, NULL, NULL, NULL, '2011-01-31 15:57:36 UTC', 497), (2327, 4, '57.0', NULL, '21.192742415229', '2011-01-31 15:58:09 UTC', 497), (2270, 4, NULL, NULL, NULL, '2011-02-03 09:49:34 UTC', 447), (2270, 4, NULL, NULL, NULL, '2011-02-03 10:08:39 UTC', 478), (2270, 4, NULL, NULL, NULL, '2011-02-03 10:09:05 UTC', 478), (2270, 4, NULL, NULL, NULL, '2011-02-03 10:12:01 UTC', 478), (2270, 4, NULL, NULL, NULL, '2011-02-03 10:12:53 UTC', 478), (2270, 4, '59.5', NULL, '22.122248661511', '2011-02-03 10:14:03 UTC', 478), (2331, 4, '50.0', NULL, '18.5901249256395', '2011-02-07 11:54:14 UTC', 456), (2271, 4, '45.0', '164.0', '16.7311124330755', '2011-02-07 16:03:44 UTC', 497), (2334, 4, '54.0', NULL, '20.0773349196907', '2011-02-18 10:40:22 UTC', 461), (2335, 4, NULL, NULL, NULL, '2011-02-23 08:49:33 UTC', 461), (2336, 4, '49.0', NULL, '18.2183224271267', '2011-03-07 09:54:56 UTC', 456), (2337, 4, '55.2', NULL, '20.523497917906', '2011-03-08 13:33:42 UTC', 478), (2338, 4, NULL, NULL, NULL, '2011-03-10 12:52:48 UTC', 461), (2339, 4, '53.0', NULL, '19.7055324211779', '2011-03-18 11:10:30 UTC', 497), (2319, 4, '59.0', NULL, '21.9363474122546', '2011-04-05 14:55:45 UTC', 427), (2275, 4, '58.0', NULL, '21.5645449137418', '2011-04-05 15:35:11 UTC', 444), (2281, 4, '58.0', NULL, '21.5645449137418', '2011-04-05 15:38:23 UTC', 444), (2291, 4, '57.0', NULL, '21.192742415229', '2011-04-05 15:41:06 UTC', 444), (2293, 4, '57.4', NULL, '21.3414634146341', '2011-04-05 15:43:40 UTC', 444), (2285, 4, '58.8', NULL, '21.8619869125521', '2011-04-05 15:46:03 UTC', 444), (2302, 4, '62.5', NULL, '23.2376561570494', '2011-04-05 15:47:58 UTC', 444), (2341, 4, '62.0', NULL, '23.051754907793', '2011-04-05 15:48:50 UTC', 444), (2342, 4, '56.0', NULL, '20.8209399167162', '2011-04-05 15:49:32 UTC', 444), (2343, 4, NULL, NULL, NULL, '2011-04-05 15:51:53 UTC', 444), (2300, 4, '56.0', NULL, '20.8209399167162', '2011-04-05 15:53:39 UTC', 444), (2273, 4, '56.0', NULL, '20.8209399167162', '2011-04-05 15:55:55 UTC', 444), (2344, 4, '60.5', NULL, '22.4940511600238', '2011-04-05 15:57:10 UTC', 444), (2297, 4, '62.0', NULL, '23.051754907793', '2011-04-05 15:57:52 UTC', 444), (2287, 4, '61.7', NULL, '22.9402141582391', '2011-04-05 15:59:18 UTC', 444), (2272, 4, '60.3', NULL, '22.4196906603212', '2011-04-05 16:00:47 UTC', 444), (2296, 4, '60.0', NULL, '22.3081499107674', '2011-04-05 16:01:47 UTC', 444), (2345, 4, NULL, NULL, NULL, '2011-04-06 09:26:30 UTC', 456), (2345, 4, '49.0', NULL, '18.2183224271267', '2011-04-11 08:46:04 UTC', 444), (2346, 4, NULL, NULL, NULL, '2011-04-21 09:49:11 UTC', 456), (2347, 4, '48.0', NULL, '17.8465199286139', '2011-05-05 10:28:43 UTC', 475), (2348, 4, NULL, NULL, NULL, '2011-05-12 11:19:56 UTC', 461), (2349, 4, '54.0', NULL, '20.0773349196907', '2011-05-17 11:39:43 UTC', 455), (2350, 4, '53.0', NULL, '19.7055324211779', '2011-06-21 14:14:33 UTC', 461), (2358, 4, '59.0', NULL, '21.9363474122546', '2011-06-23 08:52:11 UTC', 456), (2359, 4, '48.0', NULL, '17.8465199286139', '2011-07-04 10:01:25 UTC', 457), (2351, 4, '52.0', NULL, '19.3337299226651', '2011-07-26 10:46:37 UTC', 455), (2352, 4, '55.5', NULL, '20.6350386674598', '2011-08-04 09:50:29 UTC', 533), (2355, 4, '52.0', NULL, '19.3337299226651', '2011-09-23 11:58:26 UTC', 455), (2353, 4, '53.0', NULL, '19.7055324211779', '2011-10-26 13:49:13 UTC', 453), (2360, 4, '58.5', NULL, '21.7504461629982', '2012-05-31 08:46:12 UTC', 550);
