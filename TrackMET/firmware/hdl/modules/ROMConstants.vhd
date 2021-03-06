library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;


package ROMConstants is
  type intArray is array(natural range <>) of integer;
  type intArray2D is array(natural range <>) of intArray;
  constant Phi_shift : intArray(0 TO 17) := (
       (0),(0),
     (696),(696),
    (1392),(1392),
    (2088),(2088),
    (2784),(2784),
    (3480),(3480),
    (4176),(4176),
    (4872),(4872),
    (5568),(5568));



  constant TrigArray : intArray2D(0 TO 1566)(0 TO 1) := (
    (2048,0),
    (2048,2),
    (2048,4),
    (2048,6),
    (2048,8),
    (2048,10),
    (2048,12),
    (2048,14),
    (2048,16),
    (2048,18),
    (2048,21),
    (2048,23),
    (2048,25),
    (2048,27),
    (2048,29),
    (2048,31),
    (2048,33),
    (2048,35),
    (2048,37),
    (2048,39),
    (2048,41),
    (2048,43),
    (2048,45),
    (2047,47),
    (2047,49),
    (2047,51),
    (2047,53),
    (2047,55),
    (2047,58),
    (2047,60),
    (2047,62),
    (2047,64),
    (2047,66),
    (2047,68),
    (2047,70),
    (2047,72),
    (2047,74),
    (2047,76),
    (2047,78),
    (2046,80),
    (2046,82),
    (2046,84),
    (2046,86),
    (2046,88),
    (2046,90),
    (2046,92),
    (2046,94),
    (2046,97),
    (2046,99),
    (2046,101),
    (2045,103),
    (2045,105),
    (2045,107),
    (2045,109),
    (2045,111),
    (2045,113),
    (2045,115),
    (2045,117),
    (2045,119),
    (2044,121),
    (2044,123),
    (2044,125),
    (2044,127),
    (2044,129),
    (2044,131),
    (2044,133),
    (2044,135),
    (2043,138),
    (2043,140),
    (2043,142),
    (2043,144),
    (2043,146),
    (2043,148),
    (2043,150),
    (2042,152),
    (2042,154),
    (2042,156),
    (2042,158),
    (2042,160),
    (2042,162),
    (2041,164),
    (2041,166),
    (2041,168),
    (2041,170),
    (2041,172),
    (2041,174),
    (2040,176),
    (2040,178),
    (2040,181),
    (2040,183),
    (2040,185),
    (2039,187),
    (2039,189),
    (2039,191),
    (2039,193),
    (2039,195),
    (2039,197),
    (2038,199),
    (2038,201),
    (2038,203),
    (2038,205),
    (2037,207),
    (2037,209),
    (2037,211),
    (2037,213),
    (2037,215),
    (2036,217),
    (2036,219),
    (2036,221),
    (2036,223),
    (2036,226),
    (2035,228),
    (2035,230),
    (2035,232),
    (2035,234),
    (2034,236),
    (2034,238),
    (2034,240),
    (2034,242),
    (2033,244),
    (2033,246),
    (2033,248),
    (2033,250),
    (2032,252),
    (2032,254),
    (2032,256),
    (2032,258),
    (2031,260),
    (2031,262),
    (2031,264),
    (2031,266),
    (2030,268),
    (2030,270),
    (2030,272),
    (2030,274),
    (2029,276),
    (2029,279),
    (2029,281),
    (2028,283),
    (2028,285),
    (2028,287),
    (2028,289),
    (2027,291),
    (2027,293),
    (2027,295),
    (2026,297),
    (2026,299),
    (2026,301),
    (2025,303),
    (2025,305),
    (2025,307),
    (2025,309),
    (2024,311),
    (2024,313),
    (2024,315),
    (2023,317),
    (2023,319),
    (2023,321),
    (2022,323),
    (2022,325),
    (2022,327),
    (2021,329),
    (2021,331),
    (2021,333),
    (2020,335),
    (2020,337),
    (2020,339),
    (2019,341),
    (2019,343),
    (2019,346),
    (2018,348),
    (2018,350),
    (2018,352),
    (2017,354),
    (2017,356),
    (2017,358),
    (2016,360),
    (2016,362),
    (2015,364),
    (2015,366),
    (2015,368),
    (2014,370),
    (2014,372),
    (2014,374),
    (2013,376),
    (2013,378),
    (2012,380),
    (2012,382),
    (2012,384),
    (2011,386),
    (2011,388),
    (2011,390),
    (2010,392),
    (2010,394),
    (2009,396),
    (2009,398),
    (2009,400),
    (2008,402),
    (2008,404),
    (2007,406),
    (2007,408),
    (2007,410),
    (2006,412),
    (2006,414),
    (2005,416),
    (2005,418),
    (2004,420),
    (2004,422),
    (2004,424),
    (2003,426),
    (2003,428),
    (2002,430),
    (2002,432),
    (2001,434),
    (2001,436),
    (2001,438),
    (2000,440),
    (2000,442),
    (1999,444),
    (1999,446),
    (1998,448),
    (1998,450),
    (1997,452),
    (1997,454),
    (1997,456),
    (1996,458),
    (1996,460),
    (1995,462),
    (1995,464),
    (1994,466),
    (1994,468),
    (1993,470),
    (1993,472),
    (1992,474),
    (1992,476),
    (1991,478),
    (1991,480),
    (1990,482),
    (1990,484),
    (1989,486),
    (1989,488),
    (1988,490),
    (1988,492),
    (1987,494),
    (1987,496),
    (1986,498),
    (1986,500),
    (1985,502),
    (1985,504),
    (1984,506),
    (1984,508),
    (1983,510),
    (1983,512),
    (1982,514),
    (1982,516),
    (1981,518),
    (1981,520),
    (1980,522),
    (1980,524),
    (1979,526),
    (1979,528),
    (1978,530),
    (1978,532),
    (1977,534),
    (1977,536),
    (1976,538),
    (1976,540),
    (1975,542),
    (1974,544),
    (1974,546),
    (1973,548),
    (1973,550),
    (1972,552),
    (1972,554),
    (1971,556),
    (1971,558),
    (1970,560),
    (1969,562),
    (1969,564),
    (1968,566),
    (1968,568),
    (1967,570),
    (1967,572),
    (1966,574),
    (1965,576),
    (1965,578),
    (1964,579),
    (1964,581),
    (1963,583),
    (1963,585),
    (1962,587),
    (1961,589),
    (1961,591),
    (1960,593),
    (1960,595),
    (1959,597),
    (1958,599),
    (1958,601),
    (1957,603),
    (1957,605),
    (1956,607),
    (1955,609),
    (1955,611),
    (1954,613),
    (1954,615),
    (1953,617),
    (1952,619),
    (1952,621),
    (1951,623),
    (1950,625),
    (1950,627),
    (1949,629),
    (1949,631),
    (1948,632),
    (1947,634),
    (1947,636),
    (1946,638),
    (1945,640),
    (1945,642),
    (1944,644),
    (1943,646),
    (1943,648),
    (1942,650),
    (1941,652),
    (1941,654),
    (1940,656),
    (1939,658),
    (1939,660),
    (1938,662),
    (1937,664),
    (1937,666),
    (1936,668),
    (1935,669),
    (1935,671),
    (1934,673),
    (1933,675),
    (1933,677),
    (1932,679),
    (1931,681),
    (1931,683),
    (1930,685),
    (1929,687),
    (1929,689),
    (1928,691),
    (1927,693),
    (1927,695),
    (1926,697),
    (1925,699),
    (1924,700),
    (1924,702),
    (1923,704),
    (1922,706),
    (1922,708),
    (1921,710),
    (1920,712),
    (1920,714),
    (1919,716),
    (1918,718),
    (1917,720),
    (1917,722),
    (1916,724),
    (1915,725),
    (1914,727),
    (1914,729),
    (1913,731),
    (1912,733),
    (1912,735),
    (1911,737),
    (1910,739),
    (1909,741),
    (1909,743),
    (1908,745),
    (1907,747),
    (1906,748),
    (1906,750),
    (1905,752),
    (1904,754),
    (1903,756),
    (1903,758),
    (1902,760),
    (1901,762),
    (1900,764),
    (1899,766),
    (1899,768),
    (1898,769),
    (1897,771),
    (1896,773),
    (1896,775),
    (1895,777),
    (1894,779),
    (1893,781),
    (1892,783),
    (1892,785),
    (1891,787),
    (1890,788),
    (1889,790),
    (1889,792),
    (1888,794),
    (1887,796),
    (1886,798),
    (1885,800),
    (1885,802),
    (1884,804),
    (1883,806),
    (1882,807),
    (1881,809),
    (1881,811),
    (1880,813),
    (1879,815),
    (1878,817),
    (1877,819),
    (1876,821),
    (1876,822),
    (1875,824),
    (1874,826),
    (1873,828),
    (1872,830),
    (1871,832),
    (1871,834),
    (1870,836),
    (1869,837),
    (1868,839),
    (1867,841),
    (1866,843),
    (1866,845),
    (1865,847),
    (1864,849),
    (1863,851),
    (1862,852),
    (1861,854),
    (1860,856),
    (1860,858),
    (1859,860),
    (1858,862),
    (1857,864),
    (1856,866),
    (1855,867),
    (1854,869),
    (1854,871),
    (1853,873),
    (1852,875),
    (1851,877),
    (1850,879),
    (1849,880),
    (1848,882),
    (1847,884),
    (1846,886),
    (1846,888),
    (1845,890),
    (1844,892),
    (1843,893),
    (1842,895),
    (1841,897),
    (1840,899),
    (1839,901),
    (1838,903),
    (1837,904),
    (1837,906),
    (1836,908),
    (1835,910),
    (1834,912),
    (1833,914),
    (1832,915),
    (1831,917),
    (1830,919),
    (1829,921),
    (1828,923),
    (1827,925),
    (1826,926),
    (1826,928),
    (1825,930),
    (1824,932),
    (1823,934),
    (1822,936),
    (1821,937),
    (1820,939),
    (1819,941),
    (1818,943),
    (1817,945),
    (1816,947),
    (1815,948),
    (1814,950),
    (1813,952),
    (1812,954),
    (1811,956),
    (1810,957),
    (1809,959),
    (1808,961),
    (1808,963),
    (1807,965),
    (1806,967),
    (1805,968),
    (1804,970),
    (1803,972),
    (1802,974),
    (1801,976),
    (1800,977),
    (1799,979),
    (1798,981),
    (1797,983),
    (1796,985),
    (1795,986),
    (1794,988),
    (1793,990),
    (1792,992),
    (1791,994),
    (1790,995),
    (1789,997),
    (1788,999),
    (1787,1001),
    (1786,1003),
    (1785,1004),
    (1784,1006),
    (1783,1008),
    (1782,1010),
    (1781,1012),
    (1780,1013),
    (1779,1015),
    (1778,1017),
    (1777,1019),
    (1776,1020),
    (1775,1022),
    (1774,1024),
    (1773,1026),
    (1772,1028),
    (1771,1029),
    (1769,1031),
    (1768,1033),
    (1767,1035),
    (1766,1036),
    (1765,1038),
    (1764,1040),
    (1763,1042),
    (1762,1044),
    (1761,1045),
    (1760,1047),
    (1759,1049),
    (1758,1051),
    (1757,1052),
    (1756,1054),
    (1755,1056),
    (1754,1058),
    (1753,1059),
    (1752,1061),
    (1751,1063),
    (1750,1065),
    (1748,1066),
    (1747,1068),
    (1746,1070),
    (1745,1072),
    (1744,1073),
    (1743,1075),
    (1742,1077),
    (1741,1079),
    (1740,1080),
    (1739,1082),
    (1738,1084),
    (1737,1086),
    (1735,1087),
    (1734,1089),
    (1733,1091),
    (1732,1093),
    (1731,1094),
    (1730,1096),
    (1729,1098),
    (1728,1100),
    (1727,1101),
    (1726,1103),
    (1725,1105),
    (1723,1106),
    (1722,1108),
    (1721,1110),
    (1720,1112),
    (1719,1113),
    (1718,1115),
    (1717,1117),
    (1716,1119),
    (1714,1120),
    (1713,1122),
    (1712,1124),
    (1711,1125),
    (1710,1127),
    (1709,1129),
    (1708,1131),
    (1707,1132),
    (1705,1134),
    (1704,1136),
    (1703,1137),
    (1702,1139),
    (1701,1141),
    (1700,1143),
    (1699,1144),
    (1697,1146),
    (1696,1148),
    (1695,1149),
    (1694,1151),
    (1693,1153),
    (1692,1154),
    (1690,1156),
    (1689,1158),
    (1688,1159),
    (1687,1161),
    (1686,1163),
    (1685,1165),
    (1683,1166),
    (1682,1168),
    (1681,1170),
    (1680,1171),
    (1679,1173),
    (1678,1175),
    (1676,1176),
    (1675,1178),
    (1674,1180),
    (1673,1181),
    (1672,1183),
    (1671,1185),
    (1669,1186),
    (1668,1188),
    (1667,1190),
    (1666,1191),
    (1665,1193),
    (1663,1195),
    (1662,1196),
    (1661,1198),
    (1660,1200),
    (1659,1201),
    (1657,1203),
    (1656,1205),
    (1655,1206),
    (1654,1208),
    (1653,1210),
    (1651,1211),
    (1650,1213),
    (1649,1215),
    (1648,1216),
    (1646,1218),
    (1645,1220),
    (1644,1221),
    (1643,1223),
    (1642,1225),
    (1640,1226),
    (1639,1228),
    (1638,1230),
    (1637,1231),
    (1635,1233),
    (1634,1234),
    (1633,1236),
    (1632,1238),
    (1630,1239),
    (1629,1241),
    (1628,1243),
    (1627,1244),
    (1625,1246),
    (1624,1248),
    (1623,1249),
    (1622,1251),
    (1620,1252),
    (1619,1254),
    (1618,1256),
    (1617,1257),
    (1615,1259),
    (1614,1261),
    (1613,1262),
    (1612,1264),
    (1610,1265),
    (1609,1267),
    (1608,1269),
    (1606,1270),
    (1605,1272),
    (1604,1273),
    (1603,1275),
    (1601,1277),
    (1600,1278),
    (1599,1280),
    (1598,1281),
    (1596,1283),
    (1595,1285),
    (1594,1286),
    (1592,1288),
    (1591,1289),
    (1590,1291),
    (1588,1293),
    (1587,1294),
    (1586,1296),
    (1585,1297),
    (1583,1299),
    (1582,1301),
    (1581,1302),
    (1579,1304),
    (1578,1305),
    (1577,1307),
    (1575,1309),
    (1574,1310),
    (1573,1312),
    (1571,1313),
    (1570,1315),
    (1569,1316),
    (1568,1318),
    (1566,1320),
    (1565,1321),
    (1564,1323),
    (1562,1324),
    (1561,1326),
    (1560,1327),
    (1558,1329),
    (1557,1331),
    (1556,1332),
    (1554,1334),
    (1553,1335),
    (1552,1337),
    (1550,1338),
    (1549,1340),
    (1548,1341),
    (1546,1343),
    (1545,1345),
    (1543,1346),
    (1542,1348),
    (1541,1349),
    (1539,1351),
    (1538,1352),
    (1537,1354),
    (1535,1355),
    (1534,1357),
    (1533,1358),
    (1531,1360),
    (1530,1362),
    (1529,1363),
    (1527,1365),
    (1526,1366),
    (1524,1368),
    (1523,1369),
    (1522,1371),
    (1520,1372),
    (1519,1374),
    (1518,1375),
    (1516,1377),
    (1515,1378),
    (1513,1380),
    (1512,1381),
    (1511,1383),
    (1509,1384),
    (1508,1386),
    (1506,1387),
    (1505,1389),
    (1504,1390),
    (1502,1392),
    (1501,1393),
    (1499,1395),
    (1498,1396),
    (1497,1398),
    (1495,1399),
    (1494,1401),
    (1492,1402),
    (1491,1404),
    (1490,1405),
    (1488,1407),
    (1487,1408),
    (1485,1410),
    (1484,1411),
    (1483,1413),
    (1481,1414),
    (1480,1416),
    (1478,1417),
    (1477,1419),
    (1475,1420),
    (1474,1422),
    (1473,1423),
    (1471,1425),
    (1470,1426),
    (1468,1428),
    (1467,1429),
    (1465,1431),
    (1464,1432),
    (1463,1434),
    (1461,1435),
    (1460,1436),
    (1458,1438),
    (1457,1439),
    (1455,1441),
    (1454,1442),
    (1453,1444),
    (1451,1445),
    (1450,1447),
    (1448,1448),
    (1447,1450),
    (1445,1451),
    (1444,1453),
    (1442,1454),
    (1441,1455),
    (1439,1457),
    (1438,1458),
    (1436,1460),
    (1435,1461),
    (1434,1463),
    (1432,1464),
    (1431,1465),
    (1429,1467),
    (1428,1468),
    (1426,1470),
    (1425,1471),
    (1423,1473),
    (1422,1474),
    (1420,1475),
    (1419,1477),
    (1417,1478),
    (1416,1480),
    (1414,1481),
    (1413,1483),
    (1411,1484),
    (1410,1485),
    (1408,1487),
    (1407,1488),
    (1405,1490),
    (1404,1491),
    (1402,1492),
    (1401,1494),
    (1399,1495),
    (1398,1497),
    (1396,1498),
    (1395,1499),
    (1393,1501),
    (1392,1502),
    (1390,1504),
    (1389,1505),
    (1387,1506),
    (1386,1508),
    (1384,1509),
    (1383,1511),
    (1381,1512),
    (1380,1513),
    (1378,1515),
    (1377,1516),
    (1375,1518),
    (1374,1519),
    (1372,1520),
    (1371,1522),
    (1369,1523),
    (1368,1524),
    (1366,1526),
    (1365,1527),
    (1363,1529),
    (1362,1530),
    (1360,1531),
    (1358,1533),
    (1357,1534),
    (1355,1535),
    (1354,1537),
    (1352,1538),
    (1351,1539),
    (1349,1541),
    (1348,1542),
    (1346,1543),
    (1345,1545),
    (1343,1546),
    (1341,1548),
    (1340,1549),
    (1338,1550),
    (1337,1552),
    (1335,1553),
    (1334,1554),
    (1332,1556),
    (1331,1557),
    (1329,1558),
    (1327,1560),
    (1326,1561),
    (1324,1562),
    (1323,1564),
    (1321,1565),
    (1320,1566),
    (1318,1568),
    (1316,1569),
    (1315,1570),
    (1313,1571),
    (1312,1573),
    (1310,1574),
    (1309,1575),
    (1307,1577),
    (1305,1578),
    (1304,1579),
    (1302,1581),
    (1301,1582),
    (1299,1583),
    (1297,1585),
    (1296,1586),
    (1294,1587),
    (1293,1588),
    (1291,1590),
    (1289,1591),
    (1288,1592),
    (1286,1594),
    (1285,1595),
    (1283,1596),
    (1281,1598),
    (1280,1599),
    (1278,1600),
    (1277,1601),
    (1275,1603),
    (1273,1604),
    (1272,1605),
    (1270,1606),
    (1269,1608),
    (1267,1609),
    (1265,1610),
    (1264,1612),
    (1262,1613),
    (1261,1614),
    (1259,1615),
    (1257,1617),
    (1256,1618),
    (1254,1619),
    (1252,1620),
    (1251,1622),
    (1249,1623),
    (1248,1624),
    (1246,1625),
    (1244,1627),
    (1243,1628),
    (1241,1629),
    (1239,1630),
    (1238,1632),
    (1236,1633),
    (1234,1634),
    (1233,1635),
    (1231,1637),
    (1230,1638),
    (1228,1639),
    (1226,1640),
    (1225,1642),
    (1223,1643),
    (1221,1644),
    (1220,1645),
    (1218,1646),
    (1216,1648),
    (1215,1649),
    (1213,1650),
    (1211,1651),
    (1210,1653),
    (1208,1654),
    (1206,1655),
    (1205,1656),
    (1203,1657),
    (1201,1659),
    (1200,1660),
    (1198,1661),
    (1196,1662),
    (1195,1663),
    (1193,1665),
    (1191,1666),
    (1190,1667),
    (1188,1668),
    (1186,1669),
    (1185,1671),
    (1183,1672),
    (1181,1673),
    (1180,1674),
    (1178,1675),
    (1176,1676),
    (1175,1678),
    (1173,1679),
    (1171,1680),
    (1170,1681),
    (1168,1682),
    (1166,1683),
    (1165,1685),
    (1163,1686),
    (1161,1687),
    (1159,1688),
    (1158,1689),
    (1156,1690),
    (1154,1692),
    (1153,1693),
    (1151,1694),
    (1149,1695),
    (1148,1696),
    (1146,1697),
    (1144,1699),
    (1143,1700),
    (1141,1701),
    (1139,1702),
    (1137,1703),
    (1136,1704),
    (1134,1705),
    (1132,1707),
    (1131,1708),
    (1129,1709),
    (1127,1710),
    (1125,1711),
    (1124,1712),
    (1122,1713),
    (1120,1714),
    (1119,1716),
    (1117,1717),
    (1115,1718),
    (1113,1719),
    (1112,1720),
    (1110,1721),
    (1108,1722),
    (1106,1723),
    (1105,1725),
    (1103,1726),
    (1101,1727),
    (1100,1728),
    (1098,1729),
    (1096,1730),
    (1094,1731),
    (1093,1732),
    (1091,1733),
    (1089,1734),
    (1087,1735),
    (1086,1737),
    (1084,1738),
    (1082,1739),
    (1080,1740),
    (1079,1741),
    (1077,1742),
    (1075,1743),
    (1073,1744),
    (1072,1745),
    (1070,1746),
    (1068,1747),
    (1066,1748),
    (1065,1750),
    (1063,1751),
    (1061,1752),
    (1059,1753),
    (1058,1754),
    (1056,1755),
    (1054,1756),
    (1052,1757),
    (1051,1758),
    (1049,1759),
    (1047,1760),
    (1045,1761),
    (1044,1762),
    (1042,1763),
    (1040,1764),
    (1038,1765),
    (1036,1766),
    (1035,1767),
    (1033,1768),
    (1031,1769),
    (1029,1771),
    (1028,1772),
    (1026,1773),
    (1024,1774),
    (1022,1775),
    (1020,1776),
    (1019,1777),
    (1017,1778),
    (1015,1779),
    (1013,1780),
    (1012,1781),
    (1010,1782),
    (1008,1783),
    (1006,1784),
    (1004,1785),
    (1003,1786),
    (1001,1787),
    (999,1788),
    (997,1789),
    (995,1790),
    (994,1791),
    (992,1792),
    (990,1793),
    (988,1794),
    (986,1795),
    (985,1796),
    (983,1797),
    (981,1798),
    (979,1799),
    (977,1800),
    (976,1801),
    (974,1802),
    (972,1803),
    (970,1804),
    (968,1805),
    (967,1806),
    (965,1807),
    (963,1808),
    (961,1808),
    (959,1809),
    (957,1810),
    (956,1811),
    (954,1812),
    (952,1813),
    (950,1814),
    (948,1815),
    (947,1816),
    (945,1817),
    (943,1818),
    (941,1819),
    (939,1820),
    (937,1821),
    (936,1822),
    (934,1823),
    (932,1824),
    (930,1825),
    (928,1826),
    (926,1826),
    (925,1827),
    (923,1828),
    (921,1829),
    (919,1830),
    (917,1831),
    (915,1832),
    (914,1833),
    (912,1834),
    (910,1835),
    (908,1836),
    (906,1837),
    (904,1837),
    (903,1838),
    (901,1839),
    (899,1840),
    (897,1841),
    (895,1842),
    (893,1843),
    (892,1844),
    (890,1845),
    (888,1846),
    (886,1846),
    (884,1847),
    (882,1848),
    (880,1849),
    (879,1850),
    (877,1851),
    (875,1852),
    (873,1853),
    (871,1854),
    (869,1854),
    (867,1855),
    (866,1856),
    (864,1857),
    (862,1858),
    (860,1859),
    (858,1860),
    (856,1860),
    (854,1861),
    (852,1862),
    (851,1863),
    (849,1864),
    (847,1865),
    (845,1866),
    (843,1866),
    (841,1867),
    (839,1868),
    (837,1869),
    (836,1870),
    (834,1871),
    (832,1871),
    (830,1872),
    (828,1873),
    (826,1874),
    (824,1875),
    (822,1876),
    (821,1876),
    (819,1877),
    (817,1878),
    (815,1879),
    (813,1880),
    (811,1881),
    (809,1881),
    (807,1882),
    (806,1883),
    (804,1884),
    (802,1885),
    (800,1885),
    (798,1886),
    (796,1887),
    (794,1888),
    (792,1889),
    (790,1889),
    (788,1890),
    (787,1891),
    (785,1892),
    (783,1892),
    (781,1893),
    (779,1894),
    (777,1895),
    (775,1896),
    (773,1896),
    (771,1897),
    (769,1898),
    (768,1899),
    (766,1899),
    (764,1900),
    (762,1901),
    (760,1902),
    (758,1903),
    (756,1903),
    (754,1904),
    (752,1905),
    (750,1906),
    (748,1906),
    (747,1907),
    (745,1908),
    (743,1909),
    (741,1909),
    (739,1910),
    (737,1911),
    (735,1912),
    (733,1912),
    (731,1913),
    (729,1914),
    (727,1914),
    (725,1915),
    (724,1916),
    (722,1917),
    (720,1917),
    (718,1918),
    (716,1919),
    (714,1920),
    (712,1920),
    (710,1921),
    (708,1922),
    (706,1922),
    (704,1923),
    (702,1924),
    (700,1924),
    (699,1925),
    (697,1926),
    (695,1927),
    (693,1927),
    (691,1928),
    (689,1929),
    (687,1929),
    (685,1930),
    (683,1931),
    (681,1931),
    (679,1932),
    (677,1933),
    (675,1933),
    (673,1934),
    (671,1935),
    (669,1935),
    (668,1936),
    (666,1937),
    (664,1937),
    (662,1938),
    (660,1939),
    (658,1939),
    (656,1940),
    (654,1941),
    (652,1941),
    (650,1942),
    (648,1943),
    (646,1943),
    (644,1944),
    (642,1945),
    (640,1945),
    (638,1946),
    (636,1947),
    (634,1947),
    (632,1948),
    (631,1949),
    (629,1949),
    (627,1950),
    (625,1950),
    (623,1951),
    (621,1952),
    (619,1952),
    (617,1953),
    (615,1954),
    (613,1954),
    (611,1955),
    (609,1955),
    (607,1956),
    (605,1957),
    (603,1957),
    (601,1958),
    (599,1958),
    (597,1959),
    (595,1960),
    (593,1960),
    (591,1961),
    (589,1961),
    (587,1962),
    (585,1963),
    (583,1963),
    (581,1964),
    (579,1964),
    (578,1965),
    (576,1965),
    (574,1966),
    (572,1967),
    (570,1967),
    (568,1968),
    (566,1968),
    (564,1969),
    (562,1969),
    (560,1970),
    (558,1971),
    (556,1971),
    (554,1972),
    (552,1972),
    (550,1973),
    (548,1973),
    (546,1974),
    (544,1974),
    (542,1975),
    (540,1976),
    (538,1976),
    (536,1977),
    (534,1977),
    (532,1978),
    (530,1978),
    (528,1979),
    (526,1979),
    (524,1980),
    (522,1980),
    (520,1981),
    (518,1981),
    (516,1982),
    (514,1982),
    (512,1983),
    (510,1983),
    (508,1984),
    (506,1984),
    (504,1985),
    (502,1985),
    (500,1986),
    (498,1986),
    (496,1987),
    (494,1987),
    (492,1988),
    (490,1988),
    (488,1989),
    (486,1989),
    (484,1990),
    (482,1990),
    (480,1991),
    (478,1991),
    (476,1992),
    (474,1992),
    (472,1993),
    (470,1993),
    (468,1994),
    (466,1994),
    (464,1995),
    (462,1995),
    (460,1996),
    (458,1996),
    (456,1997),
    (454,1997),
    (452,1997),
    (450,1998),
    (448,1998),
    (446,1999),
    (444,1999),
    (442,2000),
    (440,2000),
    (438,2001),
    (436,2001),
    (434,2001),
    (432,2002),
    (430,2002),
    (428,2003),
    (426,2003),
    (424,2004),
    (422,2004),
    (420,2004),
    (418,2005),
    (416,2005),
    (414,2006),
    (412,2006),
    (410,2007),
    (408,2007),
    (406,2007),
    (404,2008),
    (402,2008),
    (400,2009),
    (398,2009),
    (396,2009),
    (394,2010),
    (392,2010),
    (390,2011),
    (388,2011),
    (386,2011),
    (384,2012),
    (382,2012),
    (380,2012),
    (378,2013),
    (376,2013),
    (374,2014),
    (372,2014),
    (370,2014),
    (368,2015),
    (366,2015),
    (364,2015),
    (362,2016),
    (360,2016),
    (358,2017),
    (356,2017),
    (354,2017),
    (352,2018),
    (350,2018),
    (348,2018),
    (346,2019),
    (343,2019),
    (341,2019),
    (339,2020),
    (337,2020),
    (335,2020),
    (333,2021),
    (331,2021),
    (329,2021),
    (327,2022),
    (325,2022),
    (323,2022),
    (321,2023),
    (319,2023),
    (317,2023),
    (315,2024),
    (313,2024),
    (311,2024),
    (309,2025),
    (307,2025),
    (305,2025),
    (303,2025),
    (301,2026),
    (299,2026),
    (297,2026),
    (295,2027),
    (293,2027),
    (291,2027),
    (289,2028),
    (287,2028),
    (285,2028),
    (283,2028),
    (281,2029),
    (279,2029),
    (276,2029),
    (274,2030),
    (272,2030),
    (270,2030),
    (268,2030),
    (266,2031),
    (264,2031),
    (262,2031),
    (260,2031),
    (258,2032),
    (256,2032),
    (254,2032),
    (252,2032),
    (250,2033),
    (248,2033),
    (246,2033),
    (244,2033),
    (242,2034),
    (240,2034),
    (238,2034),
    (236,2034),
    (234,2035),
    (232,2035),
    (230,2035),
    (228,2035),
    (226,2036),
    (223,2036),
    (221,2036),
    (219,2036),
    (217,2036),
    (215,2037),
    (213,2037),
    (211,2037),
    (209,2037),
    (207,2037),
    (205,2038),
    (203,2038),
    (201,2038),
    (199,2038),
    (197,2039),
    (195,2039),
    (193,2039),
    (191,2039),
    (189,2039),
    (187,2039),
    (185,2040),
    (183,2040),
    (181,2040),
    (178,2040),
    (176,2040),
    (174,2041),
    (172,2041),
    (170,2041),
    (168,2041),
    (166,2041),
    (164,2041),
    (162,2042),
    (160,2042),
    (158,2042),
    (156,2042),
    (154,2042),
    (152,2042),
    (150,2043),
    (148,2043),
    (146,2043),
    (144,2043),
    (142,2043),
    (140,2043),
    (138,2043),
    (135,2044),
    (133,2044),
    (131,2044),
    (129,2044),
    (127,2044),
    (125,2044),
    (123,2044),
    (121,2044),
    (119,2045),
    (117,2045),
    (115,2045),
    (113,2045),
    (111,2045),
    (109,2045),
    (107,2045),
    (105,2045),
    (103,2045),
    (101,2046),
    (99,2046),
    (97,2046),
    (94,2046),
    (92,2046),
    (90,2046),
    (88,2046),
    (86,2046),
    (84,2046),
    (82,2046),
    (80,2046),
    (78,2047),
    (76,2047),
    (74,2047),
    (72,2047),
    (70,2047),
    (68,2047),
    (66,2047),
    (64,2047),
    (62,2047),
    (60,2047),
    (58,2047),
    (55,2047),
    (53,2047),
    (51,2047),
    (49,2047),
    (47,2047),
    (45,2048),
    (43,2048),
    (41,2048),
    (39,2048),
    (37,2048),
    (35,2048),
    (33,2048),
    (31,2048),
    (29,2048),
    (27,2048),
    (25,2048),
    (23,2048),
    (21,2048),
    (18,2048),
    (16,2048),
    (14,2048),
    (12,2048),
    (10,2048),
    (8,2048),
    (6,2048),
    (4,2048),
    (2,2048),
    (0,2048)
  );

end ROMConstants;
  