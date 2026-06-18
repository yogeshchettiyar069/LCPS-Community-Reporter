-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: community_reporter
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `dept_id` int NOT NULL AUTO_INCREMENT,
  `dept_name` varchar(100) NOT NULL,
  `jurisdiction_area` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`dept_id`),
  UNIQUE KEY `uq_dept_name` (`dept_name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Road Maintenance',NULL,'2026-04-01 18:44:43'),(2,'Electrical',NULL,'2026-04-01 18:44:43'),(3,'Water & Sanitation',NULL,'2026-04-01 18:44:43'),(4,'Garbage Collection',NULL,'2026-04-01 18:44:43'),(5,'Parks & Recreation',NULL,'2026-04-01 18:44:43'),(6,'Building Violations',NULL,'2026-04-01 18:44:43'),(7,'Others',NULL,'2026-04-01 18:44:43');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `report_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `rating_overall` int DEFAULT NULL,
  `rating_speed` int DEFAULT NULL,
  `rating_quality` int DEFAULT NULL,
  `rating_communication` int DEFAULT NULL,
  `comment` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `report_id` (`report_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`report_id`),
  CONSTRAINT `feedback_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `message` text,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_images`
--

DROP TABLE IF EXISTS `report_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_images` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `report_id` int DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `image_type` varchar(20) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `visibility` varchar(20) DEFAULT 'AUTHORITY',
  `uploaded_by` int DEFAULT NULL,
  PRIMARY KEY (`image_id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `report_images_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_images`
--

LOCK TABLES `report_images` WRITE;
/*!40000 ALTER TABLE `report_images` DISABLE KEYS */;
INSERT INTO `report_images` VALUES (1,1,'uploads/reports/1780660794222_RoadDamage1.jpg','BEFORE','2026-06-05 11:59:54','AUTHORITY',NULL),(2,1,'uploads/9622cdad-21c8-4b03-bfbc-3cc682b8211d_RoadRepair1.jpg','AFTER','2026-06-05 12:03:54','AUTHORITY',NULL),(3,2,'uploads/reports/1780661245711_RoadDamage2.jpg','BEFORE','2026-06-05 12:07:25','AUTHORITY',NULL),(4,2,'uploads/dcc5f95c-147e-49c4-974c-b106f4218249_RoadRepair2.jpg','AFTER','2026-06-05 12:09:08','AUTHORITY',NULL),(5,3,'uploads/reports/1780661561100_RoadDamage3.jpg','BEFORE','2026-06-05 12:12:41','AUTHORITY',NULL),(6,3,'uploads/41794831-e6ec-4dbd-b75d-9c28cad91d00_RoadRepair3.jpg','AFTER','2026-06-05 12:13:18','AUTHORITY',NULL),(7,4,'uploads/reports/1780661751350_ElectricalDamage1.jpg','BEFORE','2026-06-05 12:15:51','AUTHORITY',NULL),(8,4,'uploads/2ca9cb40-b5d7-4d75-9a84-b5a4e92216a6_ElectricRepair1.jpg','AFTER','2026-06-05 12:17:09','AUTHORITY',NULL),(9,5,'uploads/reports/1780661933890_ElectricalDamage2.jpg','BEFORE','2026-06-05 12:18:53','AUTHORITY',NULL),(10,5,'uploads/0f2b20f4-69b4-49df-8b56-254647918824_ElectricRepair2.jpg','AFTER','2026-06-05 12:19:22','AUTHORITY',NULL),(11,6,'uploads/reports/1780662152359_ElectricalDamage3.jpg','BEFORE','2026-06-05 12:22:32','AUTHORITY',NULL),(12,7,'uploads/reports/1780662902127_WaterProblem1.jpg','BEFORE','2026-06-05 12:35:02','AUTHORITY',NULL),(13,7,'uploads/8bdd1d1a-c2d4-4197-b654-786c88708311_WaterSolved1.jpg','AFTER','2026-06-05 12:36:36','AUTHORITY',NULL),(14,8,'uploads/reports/1780663091280_WaterProblem2.jpg','BEFORE','2026-06-05 12:38:11','AUTHORITY',NULL),(15,9,'uploads/reports/1780663529098_GarbageProblem1.jpg','BEFORE','2026-06-05 12:45:29','AUTHORITY',NULL),(16,9,'uploads/724ecc85-5e1b-40d2-8ee1-502fcc14cbeb_GarbageSolved1.jpg','AFTER','2026-06-05 12:46:18','AUTHORITY',NULL),(17,10,'uploads/reports/1781610971212_WaterProblem1.jpg','BEFORE','2026-06-16 11:56:11','AUTHORITY',NULL),(18,10,'uploads/0efe5b78-6c05-48b1-881a-c06208d3ef60_WaterSolved2.jpeg','AFTER','2026-06-16 11:58:35','AUTHORITY',NULL);
/*!40000 ALTER TABLE `report_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_status_log`
--

DROP TABLE IF EXISTS `report_status_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_status_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `report_id` int DEFAULT NULL,
  `status` varchar(150) DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `comment` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `report_id` (`report_id`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `report_status_log_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`report_id`),
  CONSTRAINT `report_status_log_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_status_log`
--

LOCK TABLES `report_status_log` WRITE;
/*!40000 ALTER TABLE `report_status_log` DISABLE KEYS */;
INSERT INTO `report_status_log` VALUES (1,1,'Pending',2,'Report created by citizen','2026-06-05 11:59:54'),(2,1,'In Progress',5,'','2026-06-05 12:00:57'),(3,1,'Assigned',5,'Worker assigned by authority','2026-06-05 12:02:27'),(4,1,'Work Completed (Pending Approval)',12,'Worker submitted completion proof','2026-06-05 12:03:54'),(5,1,'Resolved',5,'                                ','2026-06-05 12:04:26'),(6,2,'Pending',3,'Report created by citizen','2026-06-05 12:07:25'),(7,2,'Assigned',5,'Worker assigned by authority','2026-06-05 12:08:35'),(8,2,'Work Completed (Pending Approval)',12,'Worker submitted completion proof','2026-06-05 12:09:08'),(9,2,'Resolved',5,'                                ','2026-06-05 12:09:23'),(10,3,'Pending',4,'Report created by citizen','2026-06-05 12:12:41'),(11,3,'Assigned',5,'Worker assigned by authority','2026-06-05 12:12:52'),(12,3,'Work Completed (Pending Approval)',12,'Worker submitted completion proof','2026-06-05 12:13:18'),(13,3,'Resolved',5,'                                ','2026-06-05 12:13:30'),(14,4,'Pending',2,'Report created by citizen','2026-06-05 12:15:51'),(15,4,'Assigned',6,'Worker assigned by authority','2026-06-05 12:16:29'),(16,4,'Work Completed (Pending Approval)',13,'Worker submitted completion proof','2026-06-05 12:17:09'),(17,4,'Resolved',6,'                                ','2026-06-05 12:17:22'),(18,5,'Pending',3,'Report created by citizen','2026-06-05 12:18:53'),(19,5,'Assigned',6,'Worker assigned by authority','2026-06-05 12:19:06'),(20,5,'Work Completed (Pending Approval)',13,'Worker submitted completion proof','2026-06-05 12:19:22'),(21,5,'Resolved',6,'                                ','2026-06-05 12:19:37'),(22,6,'Pending',4,'Report created by citizen','2026-06-05 12:22:32'),(23,7,'Pending',4,'Report created by citizen','2026-06-05 12:35:02'),(24,7,'Assigned',7,'Worker assigned by authority','2026-06-05 12:35:13'),(25,7,'Work Completed (Pending Approval)',14,'Worker submitted completion proof','2026-06-05 12:36:36'),(26,7,'Resolved',7,'                                ','2026-06-05 12:36:45'),(27,8,'Pending',19,'Report created by citizen','2026-06-05 12:38:11'),(28,9,'Pending',20,'Report created by citizen','2026-06-05 12:45:29'),(29,9,'Assigned',8,'Worker assigned by authority','2026-06-05 12:45:40'),(30,9,'Work Completed (Pending Approval)',15,'Worker submitted completion proof','2026-06-05 12:46:18'),(31,9,'Resolved',8,'                                ','2026-06-05 12:46:29'),(32,10,'Pending',2,'Report created by citizen','2026-06-16 11:56:11'),(33,10,'Assigned',7,'Worker assigned by authority','2026-06-16 11:57:59'),(34,10,'Work Completed (Pending Approval)',14,'Worker submitted completion proof','2026-06-16 11:58:35'),(35,10,'Resolved',7,'                                ','2026-06-16 11:59:01');
/*!40000 ALTER TABLE `report_status_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_upvotes`
--

DROP TABLE IF EXISTS `report_upvotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_upvotes` (
  `upvote_id` int NOT NULL AUTO_INCREMENT,
  `report_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `upvoted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`upvote_id`),
  UNIQUE KEY `report_id` (`report_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `report_upvotes_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`report_id`),
  CONSTRAINT `report_upvotes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_upvotes`
--

LOCK TABLES `report_upvotes` WRITE;
/*!40000 ALTER TABLE `report_upvotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_upvotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `report_code` varchar(30) DEFAULT NULL,
  `title` varchar(150) DEFAULT NULL,
  `description` text,
  `category` varchar(100) DEFAULT NULL,
  `severity` varchar(20) DEFAULT NULL,
  `priority` varchar(20) DEFAULT NULL,
  `status` varchar(150) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `citizen_id` int DEFAULT NULL,
  `assigned_dept_id` int DEFAULT NULL,
  `assigned_worker_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `report_code` (`report_code`),
  KEY `citizen_id` (`citizen_id`),
  KEY `assigned_dept_id` (`assigned_dept_id`),
  KEY `assigned_worker_id` (`assigned_worker_id`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`citizen_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`assigned_dept_id`) REFERENCES `departments` (`dept_id`),
  CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`assigned_worker_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,NULL,'Large Pothole found in Thakur Village','The issue is very serious and the road is blocked because of this no vehicle is able to move properly.',NULL,'Medium',NULL,'Resolved',19.21965800,72.81938400,2,1,12,'2026-06-05 11:59:54','2026-06-05 12:04:26'),(2,NULL,'Pothole spotted in Mahavir Nagar','It is blocking the road fix it as soon as possible.',NULL,'High',NULL,'Resolved',19.21965800,72.81937000,3,1,12,'2026-06-05 12:07:25','2026-06-05 12:09:23'),(3,NULL,'hole in the road in Dahisar east, road maintenance please fix this.','It happened as a truck accident occurred near the area and the logs felled in the road.',NULL,'High',NULL,'Resolved',19.21963600,72.81935700,4,1,12,'2026-06-05 12:12:41','2026-06-05 12:13:30'),(4,NULL,'Electrical wires causing hindrance.','heavy rain caused the wired to fell from the polls and they are messed up.',NULL,'High',NULL,'Resolved',19.21965800,72.81937000,2,2,13,'2026-06-05 12:15:51','2026-06-05 12:17:22'),(5,NULL,'electrical wire messed up in our area','please send electrician asap.',NULL,'Medium',NULL,'Resolved',19.21964500,72.81935000,3,2,13,'2026-06-05 12:18:53','2026-06-05 12:19:37'),(6,NULL,'electrical wires mess up','fix it as soon as possible.',NULL,'High',NULL,'Pending',19.21964500,72.81935000,4,2,NULL,'2026-06-05 12:22:32','2026-06-05 12:22:32'),(7,NULL,'polluted water in our locality','please fix it asap it is urgent',NULL,'Medium',NULL,'Resolved',19.21965800,72.81937000,4,3,14,'2026-06-05 12:35:02','2026-06-05 12:36:45'),(8,NULL,'water issue in jogeshwari','please come and solve this issue sashanth.',NULL,'Low',NULL,'Pending',19.21965800,72.81937000,19,3,NULL,'2026-06-05 12:38:11','2026-06-05 12:38:11'),(9,NULL,'dirty roads in mira road.','come and fix it, we think there is a leak in a sewage.',NULL,'Low',NULL,'Resolved',19.21965800,72.81937000,20,4,15,'2026-06-05 12:45:29','2026-06-05 12:46:29'),(10,NULL,'water and sanitation issue in kandivali','heavy rain caused the sewer to overflow and now the road is filled with debris',NULL,'Medium',NULL,'Resolved',19.21966500,72.81939700,2,3,14,'2026-06-16 11:56:11','2026-06-16 11:59:01');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN'),(3,'AUTHORITY'),(2,'CITIZEN'),(4,'WORKER');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int DEFAULT NULL,
  `dept_id` int DEFAULT NULL,
  `address` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `role_id` (`role_id`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  CONSTRAINT `users_ibfk_2` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@gmail.com','9867776080','admin123',1,NULL,'Kandivali (West)','2026-04-02 05:47:31'),(2,'Yogesh Chettiyar','chettiyary@gmail.com','9867776080','Yogesh456#',2,NULL,'Kandivali (West)','2026-04-02 05:53:01'),(3,'Seema Chettiyar','chettiyarseema@gmail.com','9867776080','Yogesh456#',2,NULL,'Kandivali (West)','2026-04-02 05:52:56'),(4,'Mrunal Urankar','mrunal@gmail.com','9867776080','Yogesh456#',2,NULL,'Kandivali (West)','2026-04-02 05:52:30'),(5,'Prachi Agonde','prachi@gmail.com','9867776080','Yogesh456#',3,1,'Kandivali (West)','2026-04-02 05:59:48'),(6,'Nihal Shetty','nihal@gmail.com','9867776080','Yogesh456#',3,2,'Kandivali (West)','2026-04-02 05:59:55'),(7,'Sashanth Chettiar','sashanth@gmail.com','9867776080','Yogesh456#',3,3,'Kandivali (West)','2026-04-02 06:00:01'),(8,'Prashanth Harijan','prashanth@gmail.com','9867776080','Yogesh456#',3,4,'Kandivali (West)','2026-04-02 06:00:06'),(9,'Sakshi Yadav','sakshi@gmail.com','9867776080','Yogesh456#',3,5,'Kandivali (West)','2026-04-02 06:00:12'),(10,'Arya Wargaonkar','arya@gmail.com','9867776080','Yogesh456#',3,6,'Kandivali (West)','2026-04-02 06:00:17'),(11,'Manav Phatak','manav@gmail.com','9867776080','Yogesh456#',3,7,'Kandivali (West)','2026-04-02 06:00:22'),(12,'Harsh Patel','harsh@gmail.com','9867776080','Yogesh456#',4,1,'Kandivali (West)','2026-04-02 06:01:52'),(13,'Aslesha Gupta','aslesha@gmail.com','9867776080','Yogesh456#',4,2,'Kandivali (West)','2026-04-02 06:06:23'),(14,'Anisha Kanojia','anisha@gmail.com','9867776080','Yogesh456#',4,3,'Kandivali (West)','2026-04-02 06:06:27'),(15,'Hardika Singh','hardika@gmail.com','9867776080','Yogesh456#',4,4,'Kandivali (West)','2026-04-02 06:06:32'),(16,'Jignesh Yadav','jignesh@gmail.com','9867776080','Yogesh456#',4,5,'Kandivali (West)','2026-04-02 06:06:36'),(17,'Priyanshu Singh','priyanshu@gmail.com','9867776080','Yogesh456#',4,6,'Kandivali (West)','2026-04-02 06:06:41'),(18,'Atarva Ghadge','atharva@gmail.com','9867776080','Yogesh456#',4,7,'Kandivali (West)','2026-04-02 06:06:45'),(19,'Noopur Mohite','noopur@gmail.com','1234567890','Yogesh456#',2,NULL,'Jogeshwari (East)','2026-04-02 06:14:06'),(20,'Smriti Shukla','joegoldberg6080@gmail.com','1234567890','Yogesh456#',2,NULL,'Kandivali West','2026-04-02 06:40:14');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-18 23:10:05
