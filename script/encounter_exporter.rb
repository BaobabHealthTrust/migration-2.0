
Hivfirst = EncounterType.find_by_name("HIV first visit")
Hivrecp = EncounterType.find_by_name("HIV Reception")
Artvisit = EncounterType.find_by_name("ART visit")
Heiwei = EncounterType.find_by_name("Height/Weight")
Hivstage = EncounterType.find_by_name("HIV staging")
Updateoutcome = EncounterType.find_by_name("Update outcome")
Givedrug= EncounterType.find_by_name("Give Drugs")
Preart = EncounterType.find_by_name("Pre ART visit")
Gnrlrecp= EncounterType.find_by_name("General Reception")
Opd = EncounterType.find_by_name("Outpatient diagnosis")

Height = Concept.find_by_name("Height")

Concepts = Hash.new()
Visit_encounter_hash = Hash.new()

Use_queue = 1
Output_sql = 1
Execute_sql = 1

Patient_queue = Array.new
Patient_queue_size = 1000
Guardian_queue = Array.new
Guardian_queue_size = 1000
Hiv_reception_queue = Array.new
Hiv_reception_size = 1000
General_reception_queue = Array.new
General_reception_size = 1000
Hiv_first_visit_queue = Array.new
Hiv_first_visit_size = 1000
Height_weight_queue = Array.new
Height_weight_size = 1000
Hiv_staging_queue = Array.new
Hiv_stage_size = 1000
Art_visit_queue = Array.new
Art_visit_size = 1000
Update_outcome_queue = Array.new
Patient_outcome_queue = Array.new
Outpatient_diagnosis_queue = Array.new
Outpatient_diag_size = 1000
Update_outcome_size = 1000
Patient_outcome_size = 1000
Give_drugs_queue = Array.new
Give_drugs_size = 1000
Prescriptions = Hash.new(nil)
Pre_art_visit_queue = Array.new
Pre_art_visit_size = 1000
Users_queue = Array.new
Source_db= YAML.load(File.open(File.join(RAILS_ROOT, "config/database.yml"), "r"))['bart']["database"]

CONN = ActiveRecord::Base.connection

$missing_concept_errors=0

def start

  $visit_encounter_id = 1
	
  started_at = Time.now.strftime("%Y-%m-%d-%H%M%S")

	$duplicates_outfile = File.open("./#{started_at}-duplicates.txt", "w")
	$failed_encs = File.open("./#{started_at}-Failed_encounters.txt", "w")


  if Output_sql == 1
    $visits_outfile = File.open("./migration_export_visits-" + started_at + ".sql", "w")
    $pat_encounters_outfile = File.open("./migration_export_pat_encounters-" + started_at + ".sql", "w")
    
  end

  puts "Started at : #{Time.now}"
  t1 = Time.now
  Concept.find(:all).map do |con|
    Concepts[con.id] = con
  end
  t2 = Time.now
  elapsed = time_diff_milli t1, t2
  puts "Loaded concepts in #{elapsed}"

  #you can specify the number of patients to export by adding limit then number of patiets e.g limit 100 to the query below
  patients = Patient.find_by_sql("Select * from #{Source_db}.patient where voided = 0 AND patient_id in (18534, 18544, 18575, 18606, 18615, 18639, 18773, 18789, 18802, 18839, 18631, 18885, 18890, 19011, 19121, 19126, 19148, 19278, 18558, 18594, 18680, 18907, 19480, 19653, 19674, 19688, 19768, 19799, 19962, 20881, 20023, 20021, 19552, 20089, 19568, 20118, 20123, 20162, 20234, 20229, 20246, 20241, 20268, 20263, 20286, 20299, 20312, 20386, 19587, 20420, 20429, 20440, 20445, 20458, 20477, 19010, 19014, 19016, 20564, 19034, 20583, 20084, 20679, 20768, 18801, 18824, 20817, 20844, 20865, 21177, 21219, 21307, 21372, 20677, 20692, 21685, 20706, 21738, 20751, 21807, 20778, 20796, 21897, 20835, 20853, 22040, 22043, 22061, 22091, 22163, 22187, 22231, 22248, 22365, 22377, 22401, 22456, 22629, 22716, 22721, 22769, 22801, 22821, 22846, 22953, 22944, 22979, 20917, 23131, 23122, 23306, 23363, 23389, 23437, 23448, 23505, 23506, 20354, 20610, 23667, 20607, 23718, 23719, 23730, 23746, 20585, 23771, 20570, 23799, 23811, 23822, 20495, 20526, 23868, 24063, 24103, 24172, 24218, 24233, 20695, 20701, 20727, 20747, 24323, 24350, 24363, 24386, 24447, 24487, 24519, 24566, 24599, 24634, 24640, 24646, 24649, 24548, 24656, 24578, 24707, 19739, 20620, 24904, 23438, 24780, 25060, 25066, 24717, 25094, 25098, 25195, 25212, 25267, 20424, 20182, 20649, 19571, 20789, 21039, 21558, 25404, 25406, 25409, 25431, 25529, 25617, 25623, 25629, 25653, 25687, 25837, 25857, 25869, 24141, 26135, 22419, 23635, 22476, 33700, 26145, 24534, 19110, 24766, 20454, 20425, 21866, 25621, 23421, 25468, 28149, 24119, 22808, 21620, 29209, 29224, 25519, 20014, 23704, 23956, 25840, 29262, 23728, 22961, 24224, 25460, 23916, 25012, 25675, 35577, 23431, 26121, 29298, 23200, 22664, 25573, 24029, 25571, 23481, 29387, 22465, 24678, 25450, 19706, 26149, 25844, 24358, 21339, 21733, 25894, 20707, 23305, 21452, 22996, 18542, 19006, 25615, 19667, 23558, 25677, 23261, 31898, 20678, 24667, 32254, 32280, 21453, 25539, 24666, 19701, 34416, 21327, 23024, 20416, 19235, 20821, 24054, 35356, 23022, 35590, 24948, 35596, 19722, 25886, 25651, 24127, 25831, 19214, 21269, 35956, 24096, 23569, 20830, 25880, 19954, 36458, 23016, 23745, 18951, 26336, 23772, 20070, 26379, 20542, 23167, 23824, 26105, 23784, 32518, 24920, 21619, 21437, 39041, 39091, 33720, 23807, 25495, 21430, 20316, 25991, 25865, 38910, 25123, 39723, 33879, 40395, 40439, 22129, 40623, 21240, 23296, 24049, 40998, 41119, 41121, 24544, 24432, 24870, 41587, 24134, 35608, 32248, 23384, 19944, 20278, 25476, 26119, 43583, 24088, 19220, 20272, 24336, 40978, 44929, 20166, 46510, 46517, 46514, 47221, 39269, 47409, 23443, 48330, 48351, 48370, 44265, 48418, 48464, 44322, 48801, 48912, 49670, 49638, 49692, 49718, 22893, 51273, 51518, 52001, 25982, 52079, 52093, 52103, 52108, 52110, 52112, 52114, 52375, 19159, 50842, 23457, 22107, 33648, 53335, 24110, 53389, 53391, 53395, 53400, 53406, 53265, 53404, 21010, 19719, 54903, 55526, 55528, 56041, 56595, 56620, 22994, 55532, 52126, 50268, 49656, 47285, 57058, 24664, 57364, 24019, 59007, 59736, 59768, 58973, 59867, 32737, 25480, 20820, 22907, 60127, 60875, 30804, 21803, 61528, 50514, 61821, 24309, 61923, 44881, 62679, 19631, 22778, 34420, 63603, 63883, 64139, 19657, 64511, 65514, 47279, 20890, 66674, 66717, 67558, 68023, 69070, 22224, 25896, 70125, 21355, 65693, 72221, 38178, 72530, 22768, 60784, 21505, 69594, 68665, 22687, 26139, 23884, 68866, 18795, 23452, 19246, 74966, 26615, 75019, 74936, 19022, 75060, 24109, 50874, 75482, 75497, 75502, 76034, 19576, 76110, 25390, 76706, 64183, 25762, 24637, 21677, 26034, 25779, 25749, 76146, 80237, 26169, 24001, 22520, 40962, 81310, 40972, 22852, 19923, 23685, 61621, 82414, 18737, 20244, 82388, 82357, 82461, 37395, 21434, 82420, 82431, 82406, 56175, 82443, 73860, 82747, 82763, 19958, 83368, 64388, 59779, 81547, 84447, 37275, 23025, 21284, 77299, 25440, 19687, 47832, 44511, 20119, 85137, 72265, 25191, 40913, 86441, 82909, 82921, 87272, 87852, 88850, 88853, 22742, 89069, 21550, 61452, 90672, 90772, 91661, 93070, 95503, 95535, 95539, 95541, 95764, 35147, 95799, 38108, 96766, 97447, 97745, 98175, 98300, 23893, 98044, 20928, 22060, 25535, 93256, 76370, 93273, 94631, 86358, 21486, 99172, 99245, 99248, 99250, 99254, 99252, 99256, 99260, 99262, 99264, 99406, 75883, 99574, 99594, 99675, 99885, 99898, 99901, 100207, 100202, 44151, 100350, 24482, 20975, 69101, 24151, 42738, 22779, 24165, 24411, 101230, 101268, 101245, 101253, 101279, 101286, 101288, 27496, 102008, 71642, 102186, 92317, 22167, 25689, 74257, 100124, 84759, 24158, 99881, 87945, 86512, 21843, 98992, 103655, 100239, 79304, 103690, 84090, 103713, 103718, 19077, 23263, 87319, 103409, 104192, 38131, 70744, 104568, 20238, 104720, 104931, 104941, 104944, 104950, 105124, 21536, 25834, 102029, 102023, 100335, 105618, 102196, 100235, 104952, 21189, 19921, 106373, 80229, 106512, 106520, 69127, 106730, 72444, 107549, 107629, 107677, 107699, 70620, 108763, 22795, 100342, 81292, 19334, 77201, 18536, 24185, 110179, 110197, 63872, 110278, 63874, 109769, 42381, 24619, 54711, 20466, 111003, 25900, 37792, 105952, 101762, 44815, 22888, 19845, 19796, 21446, 19920, 19965, 112215, 19686, 32016, 76159, 42346, 100662, 22562, 25283, 30711, 58793, 25452, 24184, 113101, 113673)")
  
  patient_ids = patients.map{|p| p.patient_id}
  pat_ids =  [0] if patient_ids.blank?
   

  count = patients.length
  puts "Number of patients to be migrated #{count}"

  total_enc = 0
  pat_enc = 0
  pat_outs = 0
  pat_outcomes = 0

  t1 = Time.now

  started_at = Time.now.strftime("%Y-%m-%d-%H%M%S")

  if Output_sql == 1
    $visits_outfile = File.open("./migration_export_visits-" + started_at + ".sql", "w")
    $pat_encounters_outfile = File.open("./migration_export_pat_encounters-" + started_at + ".sql", "w")
  end

  patients.each do |patient|

  	$migratedencs = Hash.new(false)
    puts "Working on patient with ID: #{patient.id}"
    pt1 = Time.now

    encounters = Encounter.find_by_sql("Select * from #{Source_db}.encounter where encounter_id in (1303187, 1685941, 1359719, 1390617, 1307446, 1307508, 1303610, 1303617, 1305049, 1303776, 1307898, 1550001, 1304580, 1517917, 1316427, 1316441, 1316459, 1381574, 1304651, 1316492, 1316501, 1316510, 1304844, 1305059, 1305127, 1308272, 1378982, 1359791, 1314709, 1314963, 1314974, 1314987, 1315034, 1315074, 1315089, 1518526, 1315122, 1315139, 1315149, 1651393, 1348742, 1306529, 1306690, 1430070, 1373418, 1581444, 1369612, 1517959, 1307372, 1685895, 1312293, 1312359, 1522662, 1314160, 1314178, 1469245, 1309480, 1475463, 1360200, 1309645, 1700685, 1561546, 1368962, 1356618, 1437872, 1372796, 1339819, 1310248, 1695672, 1695661, 1697674, 1663296, 1549548, 1396606, 1376157, 1554472, 1311492, 1697827, 1355537, 1311863, 1311860, 1379575, 1315455, 1312319, 1312455, 1562630, 1312761, 1408443, 1343129, 1313121, 1313114, 1656065, 1550039, 1313168, 1313363, 1313361, 1397614, 1313425, 1313499, 1313569, 1384663, 1333389, 1314028, 1314055, 1369348, 1314244, 1342585, 1351919, 1314302, 1314344, 1314401, 1314422, 1351417, 1368350, 1314462, 1691204, 1314587, 1662695, 1334518, 1334568, 1379899, 1315062, 1334184, 1334214, 1315171, 1315188, 1315199, 1334082, 1333678, 1333442, 1339885, 1343199, 1321787, 1321817, 1363152, 1321943, 1336821, 1336900, 1322034, 1322091, 1322128, 1359389, 1336959, 1337100, 1322281, 1322326, 1322499, 1343543, 1322931, 1323007, 1323034, 1343410, 1323098, 1323114, 1323131, 1316579, 1457342, 1369641, 1375254, 1323622, 1323646, 1316758, 1323670, 1323686, 1323694, 1483760, 1330090, 1623473, 1633814, 1435035, 1343631, 1343637, 1318853, 1663233, 1319099, 1390165, 1374111, 1561124, 1319647, 1369154, 1357067, 1501825, 1320057, 1384632, 1550276, 1381724, 1696271, 1359484, 1368684, 1627080, 1511082, 1660398, 1581241, 1343510, 1381624, 1550298, 1355293, 1534109, 1321983, 1357211, 1322275, 1322344, 1461796, 1322689, 1651034, 1351937, 1323183, 1324155, 1324157, 1355916, 1623514, 1324282, 1324473, 1433242, 1388670, 1324931, 1646310, 1355535, 1494803, 1325347, 1325466, 1325985, 1326011, 1326383, 1355910, 1610635, 1346884, 1326528, 1355858, 1355925, 1347041, 1542293, 1702073, 1327524, 1355886, 1514825, 1328024, 1328104, 1579482, 1510590, 1328423, 1368867, 1685348, 1471396, 1634132, 1680017, 1328534, 1355260, 1545820, 1328656, 1328856, 1546817, 1695640, 1425982, 1457598, 1329589, 1329496, 1355644, 1489707, 1444762, 1359490, 1378831, 1372154, 1369282, 1561081, 1330558, 1380974, 1355884, 1360373, 1652225, 1390382, 1359404, 1691117, 1331635, 1355888, 1331996, 1396513, 1332144, 1332158, 1352170, 1355862, 1332395, 1340808, 1415208, 1332446, 1517929, 1433233, 1573020, 1355906, 1332735, 1332736, 1360247, 1374912, 1346993, 1333540, 1549743, 1643363, 1355547, 1333830, 1387863, 1545804, 1333835, 1355618, 1333883, 1378964, 1333996, 1334119, 1379520, 1702403, 1381261, 1334269, 1384111, 1334325, 1334414, 1381005, 1334664, 1514954, 1623311, 1355810, 1355566, 1542198, 1451949, 1355899, 1390400, 1371170, 1335788, 1374404, 1336033, 1519055, 1433266, 1354602, 1373328, 1394382, 1345737, 1633939, 1647604, 1635133, 1336419, 1702960, 1685985, 1336681, 1355679, 1336755, 1464544, 1337236, 1404164, 1337405, 1356966, 1337486, 1337649, 1637190, 1392265, 1337942, 1633754, 1338154, 1350424, 1406199, 1348556, 1390971, 1339036, 1339043, 1338564, 1339080, 1338764, 1355880, 1690938, 1338950, 1533644, 1338979, 1339016, 1339026, 1339063, 1339070, 1446763, 1368803, 1363322, 1356548, 1339392, 1341065, 1348814, 1340982, 1392510, 1340280, 1381593, 1372687, 1355824, 1341042, 1341062, 1341188, 1341205, 1385497, 1563616, 1341633, 1341700, 1341963, 1702254, 1524182, 1561523, 1356583, 1702497, 1355688, 1352655, 1397920, 1457214, 1384423, 1355497, 1623569, 1368725, 1355904, 1355897, 1352103, 1373280, 1672119, 1355831, 1529818, 1360363, 1646666, 1537722, 1532233, 1536921, 1373337, 1660469, 1355580, 1356862, 1384874, 1345702, 1375313, 1372980, 1359055, 1494971, 1691500, 1428929, 1384737, 1536906, 1381039, 1398816, 1355867, 1514929, 1347715, 1356840, 1541912, 1518418, 1638256, 1352821, 1355392, 1379998, 1355449, 1362935, 1355595, 1355879, 1355918, 1702308, 1460807, 1362336, 1700774, 1396476, 1363467, 1363474, 1456977, 1433249, 1347210, 1384021, 1471458, 1506975, 1610624, 1355860, 1396502, 1372531, 1372757, 1396172, 1396194, 1376493, 1561029, 1550267, 1692001, 1611299, 1655844, 1507669, 1385225, 1413933, 1388059, 1568624, 1542603, 1545781, 1691303, 1405878, 1390485, 1392558, 1701027, 1687298, 1634004, 1399616, 1632155, 1417694, 1418608, 1562482, 1695598, 1467063, 1411161, 1411176, 1411175, 1481111, 1562447, 1417487, 1417494, 1417534, 1417702, 1417731, 1433275, 1419083, 1419542, 1421884, 1446078, 1421774, 1421907, 1421951, 1446072, 1463428, 1433138, 1520357, 1426820, 1427451, 1428863, 1428947, 1429015, 1429028, 1429072, 1429078, 1429097, 1581572, 1429106, 1446060, 1518602, 1429914, 1438815, 1433390, 1433254, 1433368, 1433372, 1433375, 1433379, 1433394, 1446057, 1691063, 1438564, 1440676, 1440684, 1550357, 1490023, 1446104, 1702479, 1559744, 1457710, 1510694, 1588009, 1463147, 1549770, 1464206, 1464767, 1520108, 1467613, 1471607, 1686768, 1687198, 1472751, 1474086, 1530027, 1555195, 1506421, 1581553, 1484295, 1487691, 1489527, 1511456, 1517901, 1493930, 1633896, 1667947, 1511324, 1674354, 1655884, 1642578, 1563609, 1670342, 1508079, 1551413, 1646775, 1518464, 1518064, 1518438, 1520523, 1520578, 1520600, 1628662, 1523191, 1540410, 1701002, 1626464, 1632187, 1678694, 1525681, 1685904, 1561214, 1651217, 1666096, 1540460, 1685638, 1550205, 1550150, 1550348, 1549883, 1550326, 1550341, 1550365, 1550212, 1551913, 1551919, 1569466, 1702457, 1571360, 1651313, 1647573, 1563358, 1650742, 1573022, 1655269, 1575152, 1650693, 1587539, 1587954, 1591838, 1646149, 1598934, 1623787, 1626507, 1626575, 1609446, 1609489, 1609506, 1610544, 1610634, 1615234, 1623343, 1651203, 1627145, 1627443, 1703216, 1627459, 1627489, 1627518, 1627514, 1627524, 1627550, 1627552, 1627565, 1628352, 1691161, 1629280, 1629632, 1629906, 1650628, 1630717, 1630764, 1630775, 1646901, 1632142, 1632128, 1662530, 1651216, 1660803, 1685553, 1632933, 1701998, 1637865, 1638168, 1638171, 1638074, 1638185, 1638232, 1638252, 1695542, 1685837, 1660767, 1663219, 1660518, 1642901, 1662036, 1691628, 1655341, 1651214, 1651223, 1651386, 1651388, 1655563, 1690158, 1656816, 1658101, 1658887, 1692247, 1665927, 1666857, 1666872, 1672354, 1672956, 1679196, 1687281, 1686540, 1686519, 1687278, 1703787,1303271, 1307442, 1303388, 1307506, 1307895, 1304467, 1305798, 1314959, 1306490, 1399741, 1308519, 1312286, 1312353, 1343327, 1309474, 1309717, 1310457, 1312468, 1313258, 1401898, 1314396, 1334181, 1315769, 1322277, 1316299, 1316759, 1316897, 1311608, 1343479, 1325190, 1329653, 1330530, 1333537, 1399669, 1345735, 1338318, 1338975, 1340277, 1341060, 1341185, 1341202, 1341958, 1343682, 1343705, 1343724, 1343855, 1344327, 1359995, 1344723, 1344754, 1344777, 1344858, 1345006, 1345553, 1345651, 1346544, 1379489, 1379674, 1381371, 1387552, 1369116, 1371796, 1374361, 1385231, 1383538, 1383877, 1385932, 1388143, 1388958, 1390897, 1390916, 1406052, 1413354, 1446094, 1414069, 1426789, 1433387, 1446047, 1442566, 1444444, 1444698, 1447295, 1456459, 1453528, 1455909, 1455960, 1456481, 1460157, 1587054, 1474036, 1475666, 1479317, 1484072, 1497644, 1506689, 1518640, 1520587, 1522650, 1544968, 1559748, 1554926, 1559788, 1626598, 1569054, 1579115, 1579177, 1580116, 1626597, 1626592, 1609501, 1610637, 1618085, 1619449, 1622067, 1622477, 1629508, 1641675, 1655982, 1657939, 1657966, 1658004, 1662571, 1661750, 1668076, 1672996, 1673087, 1686349, 1686962, 1691226, 1698024, 1706579)")

    #check if patient does not have update outcome encounter
    patient_encounter_types = encounters.map{|enc| enc.encounter_type}

    encounters.each do |enc|
      total_enc +=1
      pat_enc +=1
      
      visit_encounter_id = self.check_for_visitdate("#{patient.id}", enc.encounter_datetime.to_date)
      if !enc.encounter_type.blank?
      	self.create_record(visit_encounter_id, enc)
      else 
      	$failed_encs << "#{enc.encounter_id} : Missing encounter  type"
      end
    end

    self.create_patient(patient)
    self.create_guardian(patient)

    pt2 = Time.now
    elapsed = time_diff_milli pt1, pt2
    eps = total_enc / elapsed
    puts "#{pat_enc} Encounters were processed in #{elapsed} for #{eps} eps"
    puts "#{count-=1}................ patient(s) to go"
    pat_enc = 0
	                
  end

  #Create system users
  self.create_users()

  # flush the queues
  flush_patient()
  flush_hiv_first_visit()
  flush_hiv_reception()
  flush_pre_art_visit_queue()
  flush_height_weight_queue()
  flush_outpatient_diag()
  flush_general_recep()
  flush_give_drugs()
  flush_outpatient_diag()
  flush_art_visit()
  flush_hiv_staging()
  flush_update_outcome()
  flush_patient_outcome()
  flush_users()
  flush_guardians()

  if Output_sql == 1
    $visits_outfile.close()
    $pat_encounters_outfile.close()
  end

  $duplicates_outfile.close()
  puts "Finished at : #{Time.now}"
  t2 = Time.now
  elapsed = time_diff_milli t1, t2
  eps = total_enc / elapsed
  puts "#{total_enc} Encounters were processed in #{elapsed} seconds for #{eps} eps"
  puts "Encounters with missing concepts: " + $missing_concept_errors.to_s



	puts "Verifying patients"
		
	encounter_tables = ["art_visit_encounters","first_visit_encounters", "general_reception_encounters", "hiv_reception_encounters", "give_drugs_encounters", "hiv_staging_encounters", "outcome_encounters", "outpatient_diagnosis_encounters", "pre_art_visit_encounters", "vitals_encounters"]

	encounter_tables.each do |enc_type|
		puts "Encounter type : #{enc_type}"
		patients = PatientRecord.find_by_sql("select patient_id from #{enc_type} where patient_id not in (select patient_id from patients)")
		puts "#{patients.length} will be created"
		patients.each do |patient|
			self.create_patient(Patient.find(patient))
		end
		
	end

  flush_patient()

end

def time_diff_milli(start, finish)
  (finish - start)
end

def self.get_encounter(type)
  case type
    when 'ART visit'
      return Artvisit.id
    when 'HIV Reception'
      return Hivrecp.id
    when 'HIV first visit'
      return Hivfirst.id
    when 'Height/Weight'
      return Heiwei.id
    when 'HIV staging'
      return Hivstage.id
    when 'Update outcome'
      return Updateoutcome.id
    when 'Give drugs'
      return Givedrug.id
    when 'Pre ART visit'
      return Preart.id
    when 'General Reception'
    	return Gnrlrecp.id
    when 'Outpatient diagnosis'
    	return Opd.id
  end
end

def self.check_for_visitdate(patient_id, encounter_date)
  # check if we have seen this patient visit and return the visit encounter id if we have
  if Visit_encounter_hash["#{patient_id}#{encounter_date}"] != nil
    return Visit_encounter_hash["#{patient_id}#{encounter_date}"]
  end

  # make a new visit encounter
  vdate = VisitEncounter.new()
  vdate.visit_date = encounter_date
  vdate.patient_id = patient_id

  # if executing sql utilize db to generate ids
  if Execute_sql == 1
    vdate.save
    Visit_encounter_hash["#{patient_id}#{encounter_date}"] = vdate.id
  else
    # generate an id internally
    Visit_encounter_hash["#{patient_id}#{encounter_date}"] = $visit_encounter_id
    # increment the counter
    $visit_encounter_id += 1
    # assign the id to the vdate object
    vdate.id = Visit_encounter_hash["#{patient_id}#{encounter_date}"]
  end

  if Output_sql == 1
    $visits_outfile << "INSERT INTO visit_encounters (id, patient_id, visit_date) VALUES (#{vdate.id}, #{patient_id}, '#{encounter_date}');\n"
  end

  return vdate.id
end

def preprocess_insert_val(val)

  # numbers returned as strings with no quotes
  if val.kind_of? Integer
    return val.to_s
  end

  # null values returned
  if val == nil || val == ""
    return "NULL"
  end

  # escape characters and return with quotes
  val = val.to_s.gsub("'", "''")
  return "'" + val + "'"
end


def self.create_patient(pat)
  temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", pat.id])
  ids = self.get_patient_identifiers(pat.id)
  guardian = Relationship.find(:all, :conditions => ["person_id = ?", pat.id]).last 
  patient = PatientRecord.new()
  patient.patient_id = pat.id
  patient.given_name = temp.given_name rescue nil
  patient.middle_name = temp.middle_name rescue nil
  patient.family_name = temp.family_name rescue nil
  patient.gender = pat.gender
  patient.dob = pat.birthdate
  patient.dob_estimated = pat.birthdate_estimated
  patient.traditional_authority = ids["ta"]
	patient.current_address =  PatientAddress.find_by_sql("select city_village from #{Source_db}.patient_address where patient_id = #{pat.id} and voided = 0 limit 1").map{|p| p.city_village}
	patient.landmark = ids["phy_add"]
  patient.cellphone_number= ids["cell"]
  patient.home_phone_number= ids["home_phone"]
  patient.office_phone_number= ids["office_phone"]
  patient.occupation= ids["occ"]
  patient.dead = pat.dead
  patient.nat_id = ids["nat_id"]
  patient.art_number= ids["art_number"]
  patient.pre_art_number= ids["pre_arv_number"]
  patient.tb_number= ids["tb_id"]
  patient.new_nat_id= ids["new_nat_id"]
  patient.prev_art_number= ids["pre_arv_number"]
  patient.filing_number= ids["filing_number"]
  patient.archived_filing_number= ids["archived_filing_number"]
  patient.void_reason = pat.void_reason
  patient.date_voided = pat.date_voided
  patient.voided_by = pat.voided_by
  patient.date_created = pat.date_created.to_date
  patient.creator = pat.creator

	if pat.voided
	  patient.voided = 1  	
  end
  if !guardian.nil? 
  	patient.guardian_id = guardian.relative_id
  end

  if Use_queue > 0
    if Patient_queue[Patient_queue_size-1] == nil
      Patient_queue << patient
    else
      flush_patient()
      Patient_queue << patient
    end
  else
    patient.save()
  end

end

def self.create_guardian(pat)
  person_id = Person.find(:last, :conditions => ["patient_id = ? ", pat.id]).person_id rescue nil
  relatives = Relationship.find(:all, :conditions => ["person_id = ?", person_id])
  (relatives || []).each do |relative|
    guardian = Guardian.new()
    guardian_patient_id = Person.find(:last, :conditions => ["person_id = ? ", relative.relative_id]).patient_id rescue nil
    temp_relative = Patient.find(:last, :conditions => ["patient_id = ? ", guardian_patient_id]) rescue nil
    temp = PatientName.find(:last, :conditions => ["patient_id = ? and voided = 0", guardian_patient_id]) rescue nil
    guardian.patient_id = pat.id
    guardian.relative_id = guardian_patient_id
    guardian.family_name = temp.family_name rescue nil
    guardian.name = temp.given_name rescue nil
    guardian.gender = temp_relative.gender rescue nil
    guardian.relationship = RelationshipType.find(relative.relationship).name
    guardian.creator = temp_relative.creator rescue 1
    guardian.date_created = relative.date_created
    Guardian_queue << guardian
  end
end

def self.get_patient_identifiers(pat_id)

	pat_identifiers = Hash.new()	
	
	identifiers = PatientIdentifier.find(:all, :conditions => ["patient_id = ? and voided = 0", pat_id])
	identifiers.each do |id|
		id_type=PatientIdentifierType.find(id.identifier_type).name
		case id_type.upcase
			when 'NATIONAL ID' 
				pat_identifiers["nat_id"] = id.identifier
			when 'OCCUPATION'
				pat_identifiers["occ"] = id.identifier				
			when 'CELL PHONE NUMBER'
				pat_identifiers["cell"] = id.identifier			
			when 'TRADITIONAL AUTHORITY '
				pat_identifiers["ta"] = id.identifier
		  when 'PHYSICAL ADDRESS'
		    pat_identifiers['phy_add'] = id.identifier
			when 'FILING NUMBER'
				pat_identifiers["filing_number"] = id.identifier
			when 'HOME PHONE NUMBER'
				pat_identifiers["home_phone"] = id.identifier
			when 'OFFICE PHONE NUMBER'
				pat_identifiers["office_phone"] = id.identifier
			when 'ART NUMBER'
				pat_identifiers["art_number"] = id.identifier
			when 'ARV NATIONAL ID'
				pat_identifiers["art_number"] = id.identifier
			when 'PREVIOUS ART NUMBER'
				pat_identifiers["prev_art_number"] = id.identifier
			when 'NEW NATIONAL ID'
				pat_identifiers["new_nat_id"] = id.identifier
			when 'PRE ARV NUMBER ID'
				pat_identifiers["pre_arv_number"] = id.identifier
			when 'TB TREATMENT ID'
				pat_identifiers["tb_id"] = id.identifier
			when 'ARCHIVED FILING NUMBER'
				pat_identifiers["archived_filing_number"] = id.identifier
		end
	end
	return pat_identifiers
end

def self.create_record(visit_encounter_id, encounter)

  case encounter.name.upcase

    when 'HIV FIRST VISIT'
      self.create_hiv_first_visit(visit_encounter_id, encounter)
    when 'UPDATE OUTCOME'
      self.create_update_outcome(visit_encounter_id, encounter)
    when 'GIVE DRUGS'
      self.create_give_drug_record(visit_encounter_id, encounter)
    when 'HEIGHT/WEIGHT'
      self.create_vitals_record(visit_encounter_id, encounter)
    when 'HIV RECEPTION'
      self.create_hiv_reception_record(visit_encounter_id, encounter)
    when 'PRE ART VISIT'
      self.create_pre_art_record(visit_encounter_id, encounter)
    when 'ART VISIT'
      self.create_art_encounter(visit_encounter_id, encounter)
    when 'HIV STAGING'
      self.create_hiv_staging_encounter(visit_encounter_id, encounter)
    when 'OUTPATIENT DIAGNOSIS'  	
      self.create_outpatient_diag_encounter(visit_encounter_id, encounter)
    when 'GENERAL RECEPTION'
      self.create_general_encounter(visit_encounter_id, encounter)
    else
      $failed_encs << "#{encounter.encounter_id} : Invalid encounter type "
  end

end

def self.create_hiv_first_visit(visit_encounter_id, encounter)

  enc = FirstVisitEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.location = Location.find(encounter.location_id).name
  enc.visit_encounter_id = visit_encounter_id
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.old_enc_id = encounter.encounter_id
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'AGREES TO FOLLOWUP'
        enc.agrees_to_follow_up = self.get_concept(ob.value_coded)
      when 'EVER RECEIVED ART'
        enc.ever_received_arv = self.get_concept(ob.value_coded)
      when 'EVER REGISTERED AT ART CLINIC'
        enc.ever_registered_at_art = self.get_concept(ob.value_coded)
      when 'LOCATION OF FIRST POSITIVE HIV TEST'
        enc.location_of_hiv_pos_test = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'DATE OF POSITIVE HIV TEST'
        enc.date_of_hiv_pos_test = ob.value_datetime
      when 'ARV NUMBER AT THAT SITE'
        enc.arv_number_at_that_site = ob.value_numeric
      when 'LOCATION OF ART INITIATION'
        enc.location_of_art_initiation = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'TAKEN ARVS IN LAST 2 MONTHS'
        enc.taken_arvs_in_last_two_months = self.get_concept(ob.value_coded)
      when 'LAST ARV DRUGS TAKEN'
        enc.last_arv_regimen = self.get_concept(ob.value_coded)
      when 'TAKEN ART IN LAST 2 WEEKS'
        enc.taken_arvs_in_last_two_weeks = self.get_concept(ob.value_coded)
      when 'HAS TRANSFER LETTER'
        enc.has_transfer_letter = self.get_concept(ob.value_coded)
      when 'SITE TRANSFERRED FROM'
        enc.site_transferred_from = Location.find(ob.value_numeric.to_i).name rescue 'Unknown'
      when 'DATE OF ART INITIATION'
        enc.date_of_art_initiation = ob.value_datetime
      when 'DATE LAST ARVS TAKEN'
        enc.date_last_arv_taken = ob.value_datetime
      when 'WEIGHT'
        enc.weight = ob.value_numeric
      when 'HEIGHT'
        enc.height = ob.value_numeric
      when 'BMI'
        enc.bmi = (enc.weight/(enc.height*enc.height)*10000) rescue nil
    end
  end

  # check if we are to utilize the queue
	if $migratedencs[visit_encounter_id.to_s+"first_visit"] == false
		if Use_queue > 0
		  if Hiv_first_visit_queue[Hiv_first_visit_size-1] == nil
		    Hiv_first_visit_queue << enc
		  else
		    flush_hiv_first_visit()
		    Hiv_first_visit_queue << enc
		  end
		else
		  enc.save
		end
		$migratedencs[visit_encounter_id.to_s+"first_visit"] = true
	else
    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Hiv first visit \n"
	end

end

def self.create_give_drug_record(visit_encounter_id, encounter)

  enc = GiveDrugsEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.location = Location.find(encounter.location_id).name
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
	enc.pres_drug_name1 = Prescriptions[visit_encounter_id.to_s+"drug1"]
	enc.pres_dosage1 = Prescriptions[visit_encounter_id.to_s+"dosage1"]
	enc.pres_frequency1= Prescriptions[visit_encounter_id.to_s+"freq1"]
	enc.pres_drug_name2 = Prescriptions[visit_encounter_id.to_s+"drug2"]
	enc.pres_dosage2 = Prescriptions[visit_encounter_id.to_s+"dosage2"]
	enc.pres_frequency2= Prescriptions[visit_encounter_id.to_s+"freq2"]
	enc.pres_drug_name3 = Prescriptions[visit_encounter_id.to_s+"drug3"]
	enc.pres_dosage3 = Prescriptions[visit_encounter_id.to_s+"dosage3"]
	enc.pres_frequency3= Prescriptions[visit_encounter_id.to_s+"freq3"]
	enc.pres_drug_name4 = Prescriptions[visit_encounter_id.to_s+"drug4"]
	enc.pres_dosage4 = Prescriptions[visit_encounter_id.to_s+"dosage4"]
	enc.pres_frequency4= Prescriptions[visit_encounter_id.to_s+"freq4"]
	enc.pres_drug_name5 = Prescriptions[visit_encounter_id.to_s+"drug5"]
	enc.pres_dosage5 = Prescriptions[visit_encounter_id.to_s+"dosage5"]
	enc.pres_frequency5= Prescriptions[visit_encounter_id.to_s+"freq5"]
	enc.prescription_duration = Prescriptions[visit_encounter_id.to_s+"pres_duration"].to_s rescue nil
	#get the appointment_date value
	(encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'APPOINTMENT DATE'
        enc.appointment_date = ob.value_datetime
      end
   end

  #getting patient's regimen_category
  @encounter_datetime = encounter.encounter_datetime.to_date

  patient_regimen_category = Encounter.find_by_sql("select category from #{Source_db}.patient_historical_regimens where patient_id = #{encounter.patient_id} AND (encounter_id = #{encounter.encounter_id} OR DATE(dispensed_date) = '#{@encounter_datetime}')").map{|p| p.category}

  enc.regimen_category = patient_regimen_category
  enc.creator = encounter.creator  
  give_drugs_count = 1
  @quantity = 0

  (encounter.orders || []).each do |order|
    @quantity = 0
    (order.drug_orders || []).each do |drug_order|
      @quantity = @quantity + drug_order.quantity
      @drug_order =  drug_order
    end

    @patient_id = Encounter.find_by_encounter_id(order.encounter_id).patient_id
    @encounter_datetime = Encounter.find_by_encounter_id(order.encounter_id).encounter_datetime.to_date
    
    daily_consumption = []
    Patient.find_by_sql("select * from #{Source_db}.patient_prescription_totals
                   where patient_id = #{@patient_id}
                   and drug_id = #{@drug_order.drug_inventory_id}
                   and prescription_date = '#{@encounter_datetime}'").each do |dose|
                    daily_consumption << dose.daily_consumption
          end

    self.assign_drugs_dispensed(enc, @drug_order, give_drugs_count, @quantity, daily_consumption.to_s)
    give_drugs_count+=1
  end


  # check if we are to utilize the queue
  if $migratedencs[visit_encounter_id.to_s+"give_drugs"] == false
		if Use_queue > 0
		  if Give_drugs_queue[Give_drugs_size-1] == nil
		    Give_drugs_queue << enc
		  else
		    flush_give_drugs()
		    Give_drugs_queue << enc
		  end
		else
		  enc.save
		end
		
		$migratedencs[visit_encounter_id.to_s+"give_drugs"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Give drugs \n"
	end

end


def self.assign_drugs_dispensed(encounter, drug_order, count, quantity, dosage)
  case count
    when 1
      encounter.dispensed_quantity1 = quantity
      encounter.dispensed_drug_name1 = drug_order.drug.name
      encounter.dispensed_dosage1 = dosage
     # encounter.disp_drug1_start_date = drug_order.start_date
			#encounter.disp_drug1_auto_expiry_date = drug_order.auto_expire_date
    when 2
      encounter.dispensed_quantity2 = quantity
      encounter.dispensed_drug_name2 = drug_order.drug.name
      encounter.dispensed_dosage2 = dosage
      #encounter.disp_drug2_start_date = drug_order.start_date
			#encounter.disp_drug2_auto_expiry_date = drug_order.auto_expire_date
    when 3
      encounter.dispensed_quantity3 = quantity
      encounter.dispensed_drug_name3 = drug_order.drug.name
      encounter.dispensed_dosage3 = dosage
      #encounter.disp_drug3_start_date = drug_order.start_date
			#encounter.disp_drug3_auto_expiry_date = drug_order.auto_expire_date
    when 4
      encounter.dispensed_quantity4 = quantity
      encounter.dispensed_drug_name4 = drug_order.drug.name
      encounter.dispensed_dosage4 = dosage
      #encounter.disp_drug4_start_date = drug_order.start_date
			#encounter.disp_drug4_auto_expiry_date = drug_order.auto_expire_date
    when 5
		  encounter.dispensed_drug_name5 = drug_order.drug.name
      encounter.dispensed_quantity5 = quantity
      encounter.dispensed_dosage5 = dosage
      #encounter.disp_drug5_start_date = drug_order.start_date
			#encounter.disp_drug5_auto_expiry_date = drug_order.auto_expire_date
  end

end

def self.create_update_outcome(visit_encounter_id, encounter)
  enc = OutcomeEncounter.new() 

  enc.patient_id = encounter.patient_id
  enc.location = Location.find(encounter.location_id).name
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'OUTCOME'
        enc.state = self.get_concept(ob.value_coded)
        enc.outcome_date = ob.obs_datetime
      when enc.state =='Transfer Out(With Transfer Note)'
        #enc.transferred_out_location
      end
  end

	if $migratedencs[visit_encounter_id.to_s+"outcome_enc"] == false
		if Use_queue > 0
		  if Update_outcome_queue[Update_outcome_size-1] == nil
		    Update_outcome_queue << enc
		  else
		    flush_update_outcome()
		    Update_outcome_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"outcome_enc"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Update Outcome \n"
	end
	
end

def self.create_patient_outcome(outcome_id,visit_encounter_id, patient_id, outcome_concept_id, outcome_date)
    pat_outcome = PatientOutcome.new() 

    pat_outcome.visit_encounter_id = visit_encounter_id
    pat_outcome.outcome_id = outcome_id
    pat_outcome.patient_id = patient_id
    pat_outcome.outcome_state = self.get_concept(outcome_concept_id)
    pat_outcome.outcome_date = outcome_date
  
	#if $migratedencs[visit_encounter_id.to_s+"patient_outcome"] == false
		if Use_queue > 0
		  if Patient_outcome_queue[Patient_outcome_size-1] == nil
		    Patient_outcome_queue << pat_outcome
		  else
		    flush_patient_outcome()
		    Patient_outcome_queue << pat_outcome
		  end
		else
		  pat_outcome.save()
		end
		
		#$migratedencs[visit_encounter_id.to_s+"patient_outcome"] = true
		
	#else
	    $duplicates_outfile << "Enc_id: #{pat_outcome.id}, Pat_id: #{patient_id}, Enc_type: Patient Outcome \n"
	#end
end

def self.create_vitals_record(visit_encounter_id, encounter)

  enc = VitalsEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.location = Location.find(encounter.location_id).name
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  details = WeightHeightForAge.new()
  details.patient_height_weight_values(Patient.find(encounter.patient_id))
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'HEIGHT'
        enc.height = ob.value_numeric
        
      when 'WEIGHT'
        enc.weight = ob.value_numeric
        enc.weight_for_age = (enc.weight/(details.median_weight)*100).toFixed(0) rescue nil
    end
  end
  if enc.height == nil
    current_height = Observation.find(:last,
                                      :conditions => ["concept_id = ? and patient_id = ?", Height.id, encounter.patient_id]).value_numeric.to_i rescue nil
  else
    current_height = enc.height
  end
  
  enc.height_for_age = (current_height/(details.median_height)*100).toFixed(0) rescue nil
  enc.weight_for_height = ((enc.weight/details.median_weight_height)*100).toFixed(0) rescue nil
  enc.bmi = (enc.weight/(current_height*current_height)*10000) rescue nil

	if $migratedencs[visit_encounter_id.to_s+"vitals"] == false
		if  Use_queue > 0
		  if Height_weight_queue[Height_weight_size-1] == nil
		    Height_weight_queue << enc
		  else
		    flush_height_weight_queue()
		    Height_weight_queue << enc
		  end
		else
		  enc.save()
		end
	 $migratedencs[visit_encounter_id.to_s+"vitals"] = true

	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Vitals \n"
	end

end

def self.create_hiv_reception_record(visit_encounter_id, encounter)

  enc = HivReceptionEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.guardian=Relationship.find(:last, :conditions => ["person_id = ?", pat.id]).relative_id rescue nil
  enc.location = Location.find(encounter.location_id).name
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'GUARDIAN PRESENT'
        enc.guardian_present = self.get_concept(ob.value_coded)
      when 'PATIENT PRESENT'
        enc.patient_present = self.get_concept(ob.value_coded)
    end

  end

	if $migratedencs[visit_encounter_id.to_s+"hiv_reception"] == false

		if Use_queue > 0
		  if Hiv_reception_queue[Hiv_reception_size-1] == nil
		    Hiv_reception_queue << enc
		  else
		    flush_hiv_reception()
		    Hiv_reception_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"hiv_reception"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Hiv reception \n"
	end
	
end

def self.create_pre_art_record(visit_encounter_id, encounter)
  enc = PreArtVisitEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.location = Location.find(encounter.location_id).name
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  (encounter.observations || []).each do |ob|
    self.repeated_obs(enc, ob) rescue nil
  end
  drug_induced_symptom (enc) rescue nil

	if $migratedencs[visit_encounter_id.to_s+"pre_art"] == false

		if Use_queue > 0
		  if Pre_art_visit_queue[Pre_art_visit_size-1] == nil
		    Pre_art_visit_queue << enc
		  else
		    flush_pre_art_visit_queue()
		    Pre_art_visit_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"pre_art"] = true
		
	else
    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Pre ART visit \n"
	end

end

def self.assign_drugs_prescribed(id,enc, prescribed_drug_name_hash, prescribed_drug_dosage_hash, prescribed_drug_frequency_hash)
  count = 1
  (prescribed_drug_name_hash).each do |drug_name, name|
    case count
      when 1
        Prescriptions[id.to_s+"drug1"] = drug_name
        Prescriptions[id.to_s+"dosage1"] = prescribed_drug_dosage_hash[drug_name]
        Prescriptions[id.to_s+"freq1"] = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 2
        Prescriptions[id.to_s+"drug2"] = drug_name
        Prescriptions[id.to_s+"dosage2"] = prescribed_drug_dosage_hash[drug_name]
        Prescriptions[id.to_s+"freq2"] = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 3
        Prescriptions[id.to_s+"drug3"] = drug_name
        Prescriptions[id.to_s+"dosage3"] = prescribed_drug_dosage_hash[drug_name]
        Prescriptions[id.to_s+"freq3"] = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 4
        Prescriptions[id.to_s+"drug4"] = drug_name
        Prescriptions[id.to_s+"dosage4"] = prescribed_drug_dosage_hash[drug_name]
        Prescriptions[id.to_s+"freq4"] = prescribed_drug_frequency_hash[drug_name]
        count+=1
      when 5
        Prescriptions[id.to_s+"drug5"] = drug_name
        Prescriptions[id.to_s+"dosage5"] = prescribed_drug_dosage_hash[drug_name]
        Prescriptions[id.to_s+"freq5"] = prescribed_drug_frequency_hash[drug_name]
        count+=1

    end
  end
end

def self.assign_drugs_counted(encounter, obs, count)
  case count
    when 1
      encounter.drug_name_brought_to_clinic1 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic1 = obs.value_numeric rescue nil
    when 2
      encounter.drug_name_brought_to_clinic2 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic2 = obs.value_numeric rescue nil
    when 3
      encounter.drug_name_brought_to_clinic3 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic3 = obs.value_numeric rescue nil
    when 4
      encounter.drug_name_brought_to_clinic4 = Drug.find(obs.value_drug).name rescue nil
      encounter.drug_quantity_brought_to_clinic4 = obs.value_numeric rescue nil
  end
end

def self.assign_drugs_counted_but_not_brought(encounter, obs, count)
  case count
    when 1
      encounter.drug_left_at_home1 = obs.value_numeric rescue nil
    when 2
      encounter.drug_left_at_home2 = obs.value_numeric rescue nil
    when 3
      encounter.drug_left_at_home3 = obs.value_numeric rescue nil
    when 4
      encounter.drug_left_at_home4 = obs.value_numeric rescue nil
  end
end

def self.create_art_encounter(visit_encounter_id, encounter)

  enc = ArtVisitEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  enc.location = Location.find(encounter.location_id).name
  drug_name_brought_to_clinic_count = 1
  drug_name_not_brought_to_clinic_count = 1
  prescribed_drug_name_hash = {}
  prescribed_drug_dosage_hash = {}
  prescribed_drug_frequency_hash = {}

  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'WHOLE TABLETS REMAINING AND BROUGHT TO CLINIC'
        self.assign_drugs_counted(enc, ob, drug_name_brought_to_clinic_count)
        drug_name_brought_to_clinic_count+=1
      when 'WHOLE TABLETS REMAINING BUT NOT BROUGHT TO CLINIC'
        self.assign_drugs_counted_but_not_brought(enc, ob, drug_name_not_brought_to_clinic_count)
        drug_name_not_brought_to_clinic_count+=1

      when 'PRESCRIPTION TIME PERIOD'
        Prescriptions[visit_encounter_id.to_s+"pres_duration"] = ob.value_text
      when 'PRESCRIBED DOSE'
        drug_name = Drug.find(ob.value_drug).name
        @prescription_date = ob.obs_datetime.to_date
        if prescribed_drug_name_hash[drug_name].blank?
          daily_consumption = []
 
          Patient.find_by_sql("select * from #{Source_db}.patient_prescription_totals
                   where patient_id = #{ob.patient_id}
                   and drug_id = #{ob.value_drug}
                   and prescription_date = '#{@prescription_date}'").each do |dose|
                    daily_consumption << dose.daily_consumption
          end
          prescribed_drug_name_hash[drug_name] = drug_name
          prescribed_drug_dosage_hash[drug_name] = "#{daily_consumption.to_s}"
          prescribed_drug_frequency_hash[drug_name] = ob.value_text
        else
          prescribed_drug_dosage_hash[drug_name] += "-#{daily_consumption.to_s}"
          prescribed_drug_frequency_hash[drug_name] += "-#{ob.value_text}"
        end
      else
        self.repeated_obs(enc, ob)
    end
    unless prescribed_drug_name_hash.blank?
      self.assign_drugs_prescribed(visit_encounter_id, enc, prescribed_drug_name_hash, prescribed_drug_dosage_hash, prescribed_drug_frequency_hash)
    end
  end
  self.drug_induced_symptom(enc) rescue nil

	if $migratedencs[visit_encounter_id.to_s+"art"] == false
		if Use_queue > 0
		  if Art_visit_queue[Art_visit_size-1] == nil
		    Art_visit_queue << enc
		  else
		    flush_art_visit()
		    Art_visit_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"art"] = true
		
	else
    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: ART visit \n"	
	end
	
end

def self.create_outpatient_diag_encounter(visit_encounter_id, encounter)

  enc = OutpatientDiagnosisEncounter.new()

  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.location = Location.find(encounter.location_id).name
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator

  (encounter.observations || []).each do |ob|
    case ob.concept.name.upcase
      when 'SECONDARY DIAGNOSIS'
        enc.sec_diagnosis = self.get_concept(ob.value_coded)
      when 'PRIMARY DIAGNOSIS'
        enc.pri_diagnosis = self.get_concept(ob.value_coded)
      when 'DRUGS GIVEN'
      enc.treatment = self.get_concept(ob.value_coded)
    end
	end

	if $migratedencs[visit_encounter_id.to_s+"opd"] == false
	
		if Use_queue > 0
		  if Outpatient_diagnosis_queue[Outpatient_diag_size-1] == nil
		    Outpatient_diagnosis_queue << enc
		  else
		    flush_outpatient_diag()
		    Outpatient_diagnosis_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"opd"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: Outpatient Diagnosis \n"
	end
	
end

def self.create_general_encounter(visit_encounter_id, encounter)

	enc = GeneralReceptionEncounter.new()

  enc.patient_id = encounter.patient_id
  enc.visit_encounter_id = visit_encounter_id
  enc.old_enc_id = encounter.encounter_id
  enc.location = Location.find(encounter.location_id).name
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator

  (encounter.observations || []).each do |ob|
    if ob.concept.name.upcase == 'PATIENT PRESENT'
        enc.patient_present = self.get_concept(ob.value_coded) rescue 'Unknown'
    end
	end

	if $migratedencs[visit_encounter_id.to_s+"general_recp"] == false
	
		if Use_queue > 0
		  if General_reception_queue[General_reception_size-1] == nil
		    General_reception_queue << enc
		  else
		    flush_general_recep()
		    General_reception_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"general_recp"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: General Reception \n"
	end
	
end


def self.create_hiv_staging_encounter(visit_encounter_id, encounter)

  startreason = PersonAttributeType.find_by_name("reason antiretrovirals started").person_attribute_type_id
  whostage = PersonAttributeType.find_by_name("WHO stage").person_attribute_type_id
  enc = HivStagingEncounter.new()
  enc.patient_id = encounter.patient_id
  enc.old_enc_id = encounter.encounter_id
  enc.visit_encounter_id = visit_encounter_id
  enc.location = Location.find(encounter.location_id).name
  enc.date_created = encounter.date_created
  enc.encounter_datetime = encounter.encounter_datetime
  enc.creator = encounter.creator
  enc.who_stage = "WHO stage "+PersonAttribute.find(:last, :conditions => ["person_id = ? 
    AND person_attribute_type_id = ?", encounter.patient_id, whostage]).value.to_s rescue nil
  enc.reason_for_starting_art = PersonAttribute.find(:last,
                                                     :conditions => ["person_id = ? AND person_attribute_type_id = ?",
                                                                     encounter.patient_id, startreason]).value rescue nil
  (encounter.observations || []).each do |ob|
    self.repeated_obs(enc, ob)
  end

	if $migratedencs[visit_encounter_id.to_s+"hiv_staging"] == false
		
		if Use_queue > 0
		  if Hiv_staging_queue[Hiv_stage_size-1] == nil
		    Hiv_staging_queue << enc
		  else
		    flush_hiv_staging()
		    Hiv_staging_queue << enc
		  end
		else
		  enc.save()
		end
		
		$migratedencs[visit_encounter_id.to_s+"hiv_staging"] = true
		
	else
	    $duplicates_outfile << "Enc_id: #{encounter.id}, Pat_id: #{encounter.patient_id}, Enc_type: HIV Staging \n"
	end

end

def self.repeated_obs(enc, ob)

  case ob.concept.name.upcase
    when 'PREGNANT'
      enc.patient_pregnant = self.get_concept(ob.value_coded)
    when 'BREASTFEEDING'
      enc.patient_breast_feeding = self.get_concept(ob.value_coded)
    when 'CURRENTLY USING FAMILY PLANNING METHOD'
      enc.using_family_planning_method = self.get_concept(ob.value_coded)
    when 'FAMILY PLANNING METHOD'
      enc.family_planning_method_used = self.get_concept(ob.value_coded)
    when 'ABDOMINAL PAIN'
      enc.abdominal_pains = self.get_concept(ob.value_coded)
    when 'ANOREXIA'
      enc.anorexia = self.get_concept(ob.value_coded)
    when 'COUGH'
      enc.cough = self.get_concept(ob.value_coded)
    when 'DIARRHOEA'
      enc.diarrhoea = self.get_concept(ob.value_coded)
    when 'FEVER'
      enc.fever = self.get_concept(ob.value_coded)
    when 'JAUNDICE'
      enc.jaundice = self.get_concept(ob.value_coded)
    when 'LEG PAIN / NUMBNESS'
      enc.leg_pain_numbness = self.get_concept(ob.value_coded)
    when 'VOMIT'
      enc.vomit = self.get_concept(ob.value_coded)
    when 'WEIGHT LOSS'
      enc.weight_loss = self.get_concept(ob.value_coded)
		when 'OTHER SYMPTOM'	
			enc.other_symptoms = self.get_concept(ob.value_coded)
    when 'PERIPHERAL NEUROPATHY'
      enc.peripheral_neuropathy = self.get_concept(ob.value_coded)
    when 'HEPATITIS'
      enc.hepatitis = self.get_concept(ob.value_coded)
    when 'ANAEMIA'
      enc.anaemia = self.get_concept(ob.value_coded)
    when 'LACTIC ACIDOSIS'
      enc.lactic_acidosis = self.get_concept(ob.value_coded)
    when 'LIPODYSTROPHY'
      enc.lipodystrophy = self.get_concept(ob.value_coded)
    when 'SKIN RASH'
      enc.skin_rash = self.get_concept(ob.value_coded)
    when 'TB STATUS'
      enc.tb_status = self.get_concept(ob.value_coded)
    when 'REFER PATIENT TO CLINICIAN'
      enc.refer_to_clinician = self.get_concept(ob.value_coded)
    when 'PRESCRIBE ARVS THIS VISIT'
      enc.prescribe_arv = self.get_concept(ob.value_coded)
    #when 'PRESCRIPTION TIME PERIOD'
     # enc.prescription_duration = self.get_concept(ob.value_coded)
    when 'ARV REGIMEN'
      enc.arv_regimen = self.get_concept(ob.value_coded)
    when 'PRESCRIBE COTRIMOXAZOLE (CPT)'
      enc.prescribe_cpt = self.get_concept(ob.value_coded)
    when 'PRESCRIBED ISONIAZED (IPT)'
      enc.prescribe_ipt = self.get_concept(ob.value_coded)
    when 'NUMBER OF CONDOMS GIVEN'
      enc.number_of_condoms_given = ob.value_numeric
    when 'PRESCRIBED DEPO PROVERA'
      enc.depo_provera_given = self.get_concept(ob.value_coded)
    when 'CONTINUE TREATMENT AT CURRENT CLINIC'
      enc.continue_treatment_at_clinic = self.get_concept(ob.value_coded)
    when 'CONTINUE ART'
      enc.continue_art = self.get_concept(ob.value_coded)
    when 'CD4 COUNT AVAILABLE'
      enc.cd4_count_available = self.get_concept(ob.value_coded)
    when 'CD4 COUNT'
      enc.cd4_count = ob.value_numeric
      enc.cd4_count_modifier = ob.value_modifier
    when 'CD4 COUNT PERCENTAGE'
      enc.cd4_count_percentage = ob.value_numeric
    when 'CD4 TEST DATE'
      enc.date_of_cd4_count = ob.value_datetime
    when 'ASYMPTOMATIC'
      enc.asymptomatic = self.get_concept(ob.value_coded)
    when 'PERSISTENT GENERALISED LYMPHADENOPATHY'
      enc.persistent_generalized_lymphadenopathy = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 1 CONDITION'
      enc.unspecified_stage_1_cond= self.get_concept(ob.value_coded)
    when 'MOLLUSCUMM CONTAGIOSUM'
      enc.molluscumm_contagiosum = self.get_concept(ob.value_coded)
    when 'WART VIRUS INFECTION, EXTENSIVE'
      enc.wart_virus_infection_extensive = self.get_concept(ob.value_coded)
    when 'ORAL ULCERATIONS, RECURRENT'
      enc.oral_ulcerations_recurrent = self.get_concept(ob.value_coded)
    when 'PAROTID ENLARGEMENT, PERSISTENT UNEXPLAINED'
      enc.parotid_enlargement_persistent_unexplained = self.get_concept(ob.value_coded)
    when 'LINEAL GINGIVAL ERYTHEMA'
      enc.lineal_gingival_erythema = self.get_concept(ob.value_coded)
    when 'HERPES ZOSTER'
      enc.herpes_zoster = self.get_concept(ob.value_coded)
    when 'RESPIRATORY TRACT INFECTIONS, RECURRENT(SINUSITIS, TONSILLITIS, OTITIS MEDIA, PHARYNGITIS)'
      enc.respiratory_tract_infections_recurrent = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 2 CONDITION'
      enc.unspecified_stage2_condition =self.get_concept(ob.value_coded)
    when 'ANGULAR CHEILITIS'
      enc.angular_chelitis = self.get_concept(ob.value_coded)
    when 'PAPULAR PRURITIC ERUPTIONS / FUNGAL NAIL INFECTIONS'
      enc.papular_prurtic_eruptions = self.get_concept(ob.value_coded)
    when 'HEPATOSPLENOMEGALY, PERSISTENT UNEXPLAINED'
      enc.hepatosplenomegaly_unexplained = self.get_concept(ob.value_coded)
    when 'ORAL HAIRY LEUKOPLAKIA'
      enc.oral_hairy_leukoplakia =self.get_concept(ob.value_coded)
    when 'SEVERE WEIGHT LOSS >10% AND/OR BMI <18.5KG/M(SQUARED), UNEXPLAINED'
      enc.severe_weight_loss = self.get_concept(ob.value_coded)
    when 'FEVER, PERSISTENT UNEXPLAINED (INTERMITTENT OR CONSTANT, > 1 MONTH)'
      enc.fever_persistent_unexplained = self.get_concept(ob.value_coded)
    when 'PULMONARY TUBERCULOSIS (CURRENT)'
      enc.pulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when 'PULMONARY TUBERCULOSIS WITHIN THE LAST 2 YEARS'
      enc.pulmonary_tuberculosis_last_2_years = self.get_concept(ob.value_coded)
    when 'SEVERE BACTERIAL INFECTIONS (PNEUMONIA, EMPYEMA, PYOMYOSITIS, BONE/JOINT, MENINGITIS, BACTERAEMIA)'
      enc.severe_bacterial_infection = self.get_concept(ob.value_coded)
    when 'BACTERIAL PNEUMONIA, RECURRENT SEVERE'
      enc.bacterial_pnuemonia = self.get_concept(ob.value_coded)
    when 'SYMPTOMATIC LYMPHOID INTERSTITIAL PNEUMONITIS'
      enc.symptomatic_lymphoid_interstitial_pnuemonitis = self.get_concept(ob.value_coded)
    when 'CHRONIC HIV-ASSOCIATED LUNG DISEASE INCLUDING BRONCHIECTASIS'
      enc.chronic_hiv_assoc_lung_disease = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 3 CONDITION'
      enc.unspecified_stage3_condition = self.get_concept(ob.value_coded)
    when 'ANAEMIA'
      enc.aneamia = self.get_concept(ob.value_coded)
    when 'NEUTROPAENIA, UNEXPLAINED < 500 /MM(CUBED)'
      enc.neutropaenia = self.get_concept(ob.value_coded)
    when 'THROMBOCYTOPAENIA, CHRONIC < 50,000 /MM(CUBED)'
      enc.thrombocytopaenia_chronic = self.get_concept(ob.value_coded)
    when 'DIARRHOEA'
      enc.diarhoea = self.get_concept(ob.value_coded)
    when 'ORAL CANDIDIASIS'
      enc.oral_candidiasis = self.get_concept(ob.value_coded)
    when 'ACUTE NECROTIZING ULCERATIVE GINGIVITIS OR PERIODONTITIS'
      enc.acute_necrotizing_ulcerative_gingivitis = self.get_concept(ob.value_coded)
    when 'LYMPH NODE TUBERCLOSIS'
      enc.lymph_node_tuberculosis = self.get_concept(ob.value_coded)
    when 'TOXOPLASMOSIS OF THE BRAIN'
      enc.toxoplasmosis_of_brain = self.get_concept(ob.value_coded)
    when 'CRYPTOCOCCAL MENINGITIS'
      enc.cryptococcal_meningitis = self.get_concept(ob.value_coded)
    when 'PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY'
      enc.progressive_multifocal_leukoencephalopathy = self.get_concept(ob.value_coded)
    when 'DISSEMINATED MYCOSIS (COCCIDIOMYCOSIS OR HISTOPLASMOSIS)'
      enc.disseminated_mycosis = self.get_concept(ob.value_coded)
    when 'CANDIDIASIS OF OESOPHAGUS'
      enc.candidiasis_of_oesophagus = self.get_concept(ob.value_coded)
    when 'EXTRAPULMONARY TUBERCULOSIS'
      enc.extrapulmonary_tuberculosis = self.get_concept(ob.value_coded)
    when 'CEREBRAL OR B-CELL NON-HODGKIN LYMPHOMA'
      enc.cerebral_non_hodgkin_lymphoma = self.get_concept(ob.value_coded)
    when "KAPOSI'S SARCOMA"
      enc.kaposis = self.get_concept(ob.value_coded)
    when 'HIV ENCEPHALOPATHY'
      enc.hiv_encephalopathy = self.get_concept(ob.value_coded)
    when 'UNSPECIFIED STAGE 4 CONDITION'
      enc.unspecified_stage_4_condition = self.get_concept(ob.value_coded)
    when 'PNEUMOCYSTIS PNEUMONIA'
      enc.pnuemocystis_pnuemonia = self.get_concept(ob.value_coded)
    when 'DISSEMINATED NON-TUBERCLOSIS MYCOBACTERIAL INFECTION'
      enc.disseminated_non_tuberculosis_mycobactierial_infection = self.get_concept(ob.value_coded)
    when 'CRYPTOSPORIDIOSIS OR ISOSPORIASIS'
      enc.cryptosporidiosis = self.get_concept(ob.value_coded)
    when 'ISOSPORIASIS >1 MONTH'
      enc.isosporiasis = self.get_concept(ob.value_coded)
    when 'SYMPTOMATIC HIV-ASSOCIATED NEPHROPATHY OR CARDIOMYOPATHY'
      enc.symptomatic_hiv_asscoiated_nephropathy = self.get_concept(ob.value_coded)
    when 'CHRONIC HERPES SIMPLEX INFECTION(OROLABIAL, GENITAL / ANORECTAL >1 MONTH OR VISCERAL AT ANY SITE)'
      enc.chronic_herpes_simplex_infection = self.get_concept(ob.value_coded)
    when 'CYTOMEGALOVIRUS INFECTION (RETINITIS OR INFECTION OF OTHER ORGANS)'
      enc.cytomegalovirus_infection = self.get_concept(ob.value_coded)
    when 'TOXOPLASMOSIS OF THE BRAIN (FROM AGE 1 MONTH)'
      enc.toxoplasomis_of_the_brain_1month = self.get_concept(ob.value_coded)
    when 'RECTO-VAGINAL FISTULA, HIV-ASSOCIATED'
      enc.recto_vaginal_fitsula = self.get_concept(ob.value_coded)
    when 'HIV WASTING SYNDROME (SEVERE WEIGHT LOSS + PERSISTENT FEVER OR SEVERE LOSS + CHRONIC DIARRHOEA)'
      enc.hiv_wasting_syndrome = self.get_concept(ob.value_coded)
    when 'REASON ANTIRETROVIRALS STARTED'
      enc.reason_for_starting_art = self.get_concept(ob.value_coded)
    when 'WHO STAGE'
      enc.who_stage = self.get_concept(ob.value_coded)

  end
end

def self.drug_induced_symptom (enc)
  if enc.lipodystrophy.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_lipodystrophy = 'Yes'
  end
  if enc.abdominal_pains.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_abdominal_pains = 'Yes'
  end
  if enc.skin_rash.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_skin_rash = 'Yes'
  end
  if enc.anorexia.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_anorexia = 'Yes'
  end
  if enc.diarrhoea.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_diarrhoea = 'Yes'
  end
  if enc.jaundice.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_jaundice = 'Yes'
  end
  if enc.leg_pain_numbness.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_leg_pain_numbness = 'Yes'
  end
  if enc.vomit.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_vomit = 'Yes'
  end
  if enc.peripheral_neuropathy.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_peripheral_neuropathy = 'Yes'
  end
  if enc.hepatitis.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_hepatitis = 'Yes'
  end
  if enc.anaemia.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_anaemia = 'Yes'
  end
  if enc.lactic_acidosis.upcase == 'YES DRUG INDUCED'
    enc.drug_induced_lactic_acidosis = 'Yes'
  end

end

def self.get_concept(id)
  begin
    if Concepts[id] == nil
      return Concept.find(id).name
    else
      return Concepts[id].name
    end
  rescue
    $missing_concept_errors += 1
    Concept.find_by_name('Missing').id
  end

end

def preprocess_insert_val(val)

  # numbers returned as strings with no quotes
  if val.kind_of? Integer
    return val.to_s
  end

  # null values returned
  if val == nil || val == ""
    return "NULL"
  end

  # escape characters and return with quotes
  val = val.to_s.gsub("'", "''")
  return "'" + val + "'"
end

def flush_patient()

  flush_queue(Patient_queue, "patients", ['patient_id','given_name', 'middle_name', 'family_name', 'gender', 'dob', 'dob_estimated', 'dead', 'traditional_authority','guardian_id', 'current_address', 'landmark', 'cellphone_number', 'home_phone_number', 'office_phone_number', 'occupation', 'nat_id', 'art_number', 'pre_art_number', 'tb_number', 'legacy_id', 'legacy_id2', 'legacy_id3', 'new_nat_id', 'prev_art_number', 'filing_number', 'archived_filing_number', 'voided', 'void_reason', 'date_voided', 'voided_by', 'date_created', 'creator'])

end

def flush_hiv_reception()

  flush_queue(Hiv_reception_queue, "hiv_reception_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'patient_present', 'guardian_present','location', 'encounter_datetime', 'date_created', 'creator'])

end


def flush_height_weight_queue()

  flush_queue(Height_weight_queue, "vitals_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'weight', 'height', 'bmi','location', 'encounter_datetime', 'date_created', 'creator'])

end

def flush_pre_art_visit_queue()

  flush_queue(Pre_art_visit_queue, "pre_art_visit_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'abdominal_pains', 'using_family_planning_method', 'family_planning_method_in_use', 'anorexia', 'cough', 'diarrhoea', 'fever', 'jaundice', 'leg_pain_numbness', 'vomit', 'weight_loss', 'peripheral_neuropathy', 'hepatitis', 'anaemia', 'lactic_acidosis', 'lipodystrophy', 'skin_rash', 'drug_induced_abdominal_pains', 'drug_induced_anorexia', 'drug_induced_diarrhoea', 'drug_induced_jaundice', 'drug_induced_leg_pain_numbness', 'drug_induced_vomit', 'drug_induced_peripheral_neuropathy', 'drug_induced_hepatitis', 'drug_induced_anaemia', 'drug_induced_lactic_acidosis', 'drug_induced_lipodystrophy', 'drug_induced_skin_rash', 'drug_induced_other_symptom', 'tb_status', 'refer_to_clinician', 'prescribe_cpt', 'prescription_duration', 'number_of_condoms_given', 'prescribe_ipt','location','encounter_datetime', 'date_created', 'creator'])

end

def flush_outpatient_diag()

	flush_queue(Outpatient_diagnosis_queue,'outpatient_diagnosis_encounters',['visit_encounter_id','old_enc_id', 'patient_id','pri_diagnosis','sec_diagnosis','treatment','location', 'voided', 'void_reason', 'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
	
end

def flush_general_recep()

	flush_queue(General_reception_queue, 'general_reception_encounters',['visit_encounter_id','old_enc_id', 'patient_id','patient_present','location', 'voided', 'void_reason', 'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
end

def flush_hiv_first_visit

  flush_queue(Hiv_first_visit_queue, "first_visit_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'agrees_to_follow_up', 'date_of_hiv_pos_test', 'date_of_hiv_pos_test_estimated', 'location_of_hiv_pos_test', 'arv_number_at_that_site', 'location_of_art_initiation', 'taken_arvs_in_last_two_months', 'taken_arvs_in_last_two_weeks', 'has_transfer_letter', 'site_transferred_from', 'date_of_art_initiation', 'ever_registered_at_art', 'ever_received_arv', 'last_arv_regimen', 'date_last_arv_taken', 'date_last_arv_taken_estimated', 'weight', 'height', 'bmi','location', 'voided', 'void_reason', 'date_voided', 'voided_by', 'encounter_datetime', 'date_created', 'creator'])

end

def flush_give_drugs()

 flush_queue(Give_drugs_queue, "give_drugs_encounters", ['visit_encounter_id','old_enc_id', 'patient_id','pres_drug_name1','pres_dosage1','pres_frequency1','pres_drug_name2','pres_dosage2','pres_frequency2', 'pres_drug_name3','pres_dosage3','pres_frequency3','pres_drug_name4','pres_dosage4','pres_frequency4','pres_drug_name5', 'pres_dosage5','pres_frequency5','prescription_duration','dispensed_drug_name1', 'dispensed_quantity1','dispensed_dosage1', 'dispensed_drug_name2', 'dispensed_quantity2', 'dispensed_dosage2', 'dispensed_drug_name3', 'dispensed_quantity3', 'dispensed_dosage3', 'dispensed_drug_name4', 'dispensed_quantity4', 'dispensed_dosage4', 'dispensed_drug_name5', 'dispensed_quantity5', 'dispensed_dosage5', 'appointment_date', 'regimen_category', 'location', 'voided', 'void_reason', 'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
 	Prescriptions.clear()
end

def flush_hiv_first_visit
  flush_queue(Hiv_first_visit_queue, "first_visit_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'agrees_to_follow_up', 'date_of_hiv_pos_test', 'date_of_hiv_pos_test_estimated', 'location_of_hiv_pos_test', 'arv_number_at_that_site', 'location_of_art_initiation', 'taken_arvs_in_last_two_months', 'taken_arvs_in_last_two_weeks', 'has_transfer_letter', 'site_transferred_from', 'date_of_art_initiation', 'ever_registered_at_art', 'ever_received_arv', 'last_arv_regimen', 'date_last_arv_taken', 'date_last_arv_taken_estimated', 'weight', 'height', 'bmi', 'location','voided', 'void_reason', 'date_voided', 'voided_by', 'encounter_datetime', 'date_created', 'creator'])
end

def flush_art_visit()
  flush_queue(Art_visit_queue, "art_visit_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'using_family_planning_method', 'family_planning_method_used', 'abdominal_pains', 'anorexia', 'cough', 'diarrhoea', 'fever', 'jaundice', 'leg_pain_numbness', 'vomit', 'weight_loss', 'peripheral_neuropathy', 'hepatitis', 'anaemia', 'lactic_acidosis', 'lipodystrophy', 'skin_rash', 'other_symptoms', 'drug_induced_Abdominal_pains', 'drug_induced_anorexia', 'drug_induced_diarrhoea', 'drug_induced_jaundice', 'drug_induced_leg_pain_numbness', 'drug_induced_vomit', 'drug_induced_peripheral_neuropathy', 'drug_induced_hepatitis', 'drug_induced_anaemia', 'drug_induced_lactic_acidosis', 'drug_induced_lipodystrophy', 'drug_induced_skin_rash', 'drug_induced_other_symptom', 'tb_status', 'refer_to_clinician', 'prescribe_arv', 'drug_name_brought_to_clinic1', 'drug_quantity_brought_to_clinic1', 'drug_left_at_home1', 'drug_name_brought_to_clinic2', 'drug_quantity_brought_to_clinic2', 'drug_left_at_home2', 'drug_name_brought_to_clinic3', 'drug_quantity_brought_to_clinic3', 'drug_left_at_home3', 'drug_name_brought_to_clinic4', 'drug_quantity_brought_to_clinic4', 'drug_left_at_home4', 'arv_regimen','prescribe_cpt', 'number_of_condoms_given', 'depo_provera_given', 'continue_treatment_at_clinic','continue_art','location', 'voided', 'void_reason',  'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
end

def flush_hiv_staging()
  flush_queue(Hiv_staging_queue, "hiv_staging_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'patient_pregnant', 'patient_breast_feeding', 'cd4_count_available', 'cd4_count', 'cd4_count_modifier', 'cd4_count_percentage', 'date_of_cd4_count', 'asymptomatic', 'persistent_generalized_lymphadenopathy', 'unspecified_stage_1_cond', 'molluscumm_contagiosum', 'wart_virus_infection_extensive', 'oral_ulcerations_recurrent', 'parotid_enlargement_persistent_unexplained', 'lineal_gingival_erythema', 'herpes_zoster', 'respiratory_tract_infections_recurrent', 'unspecified_stage2_condition', 'angular_chelitis', 'papular_prurtic_eruptions', 'hepatosplenomegaly_unexplained', 'oral_hairy_leukoplakia', 'severe_weight_loss', 'fever_persistent_unexplained', 'pulmonary_tuberculosis', 'pulmonary_tuberculosis_last_2_years', 'severe_bacterial_infection', 'bacterial_pnuemonia', 'symptomatic_lymphoid_interstitial_pnuemonitis', 'chronic_hiv_assoc_lung_disease', 'unspecified_stage3_condition', 'aneamia', 'neutropaenia', 'thrombocytopaenia_chronic', 'diarhoea', 'oral_candidiasis', 'acute_necrotizing_ulcerative_gingivitis', 'lymph_node_tuberculosis', 'toxoplasmosis_of_brain', 'cryptococcal_meningitis', 'progressive_multifocal_leukoencephalopathy', 'disseminated_mycosis', 'candidiasis_of_oesophagus', 'extrapulmonary_tuberculosis', 'cerebral_non_hodgkin_lymphoma', 'kaposis', 'hiv_encephalopathy', 'bacterial_infections_severe_recurrent', 'unspecified_stage_4_condition', 'pnuemocystis_pnuemonia', 'disseminated_non_tuberculosis_mycobactierial_infection', 'cryptosporidiosis', 'isosporiasis', 'symptomatic_hiv_asscoiated_nephropathy', 'chronic_herpes_simplex_infection', 'cytomegalovirus_infection', 'toxoplasomis_of_the_brain_1month', 'recto_vaginal_fitsula', 'hiv_wasting_syndrome', 'reason_for_starting_art', 'who_stage','location', 'voided', 'void_reason', 'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
end

def flush_update_outcome()
  flush_queue(Update_outcome_queue, "outcome_encounters", ['visit_encounter_id','old_enc_id', 'patient_id', 'state', 'outcome_date', 'transferred_out_location','location', 'voided', 'void_reason', 'encounter_datetime', 'date_voided', 'voided_by', 'date_created', 'creator'])
end

def flush_patient_outcome()
  flush_queue(Patient_outcome_queue, "patient_outcomes", ['visit_encounter_id', 'patient_id', 'outcome_state', 'outcome_date'])
end

def flush_users()
  flush_queue(Users_queue, 'users', ['username', 'first_name', 'middle_name', 'last_name', 'password', 'salt', 'user_role1', 'user_role2', 'user_role3', 'user_role4', 'user_role5', 'user_role6', 'user_role7', 'user_role8', 'user_role9', 'user_role10', 'date_created', 'voided', 'void_reason', 'date_voided', 'voided_by', 'creator'])
end

def flush_guardians()
  flush_queue(Guardian_queue, "guardians", ['patient_id', 'relative_id', 'family_name', 'name', 'gender', 'relationship', 'creator', 'date_created'])
end

def flush_queue(queue, table, columns)
  if queue.length == 0
    return
  end

  insert_vals = columns

  inserts = []

  queue.each { |e|
    i = ("(")
    insert_vals.each { |insert_val|
      i += preprocess_insert_val(eval("e.#{insert_val}"))
      i += ", "
    }
    # remove last comma space before appending the end parenthesis
    i = i.chop.chop
    i += ")"
    inserts << i
  }

  sql = "INSERT INTO #{table} (#{insert_vals.join(", ")}) VALUES #{inserts.join(", ")}"

  if Output_sql == 1
    $pat_encounters_outfile << sql + ";\n"
  end

  if Execute_sql == 1
    CONN.execute sql
  end

  queue.clear()
end


def self.create_users()
  users = User.find_by_sql("Select* from  #{Source_db}.users")

  users.each do |user|
    new_user = MigratedUsers.new()
    
    user_roles = User.find_by_sql("SELECT r.role FROM #{Source_db}.user_role ur 
                                       INNER JOIN #{Source_db}.role r ON r.role_id = ur.role_id
                                       WHERE user_id = #{user.user_id}").map{|role| role.role}

    new_user.username = user.username
    new_user.first_name = user.first_name
    new_user.middle_name = user.middle_name
    new_user.last_name = user.last_name
    new_user.password = user.password
    new_user.salt = user.salt
    new_user.user_role1 = user_roles[0]
    new_user.user_role2 = user_roles[1]
    new_user.user_role3 = user_roles[2]
    new_user.user_role4 = user_roles[3]
    new_user.user_role5 = user_roles[4]
    new_user.user_role6 = user_roles[5]
    new_user.user_role7 = user_roles[6]
    new_user.user_role8 = user_roles[7]
    new_user.user_role9 = user_roles[8]
    new_user.user_role10 = user_roles[9]
    new_user.date_created = user.date_created
    new_user.voided = user.voided
    new_user.void_reason = user.void_reason
    new_user.date_voided = user.date_voided
    new_user.voided_by = user.voided_by
    new_user.creator = user.creator
    Users_queue << new_user
  end
end

start

