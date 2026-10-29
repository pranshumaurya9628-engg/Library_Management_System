-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: sehatsetu_db
-- ------------------------------------------------------
-- Server version	8.0.46

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
-- Table structure for table `admin_activity_logs`
--

DROP TABLE IF EXISTS `admin_activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_activity_logs` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `action` varchar(150) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  `details` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_activity_admin` (`admin_id`),
  KEY `idx_activity_created` (`created_at`),
  KEY `idx_activity_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `fk_activity_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_activity_logs`
--

LOCK TABLES `admin_activity_logs` WRITE;
/*!40000 ALTER TABLE `admin_activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article_categories`
--

DROP TABLE IF EXISTS `article_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `article_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `category_name` (`category_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article_categories`
--

LOCK TABLES `article_categories` WRITE;
/*!40000 ALTER TABLE `article_categories` DISABLE KEYS */;
INSERT INTO `article_categories` VALUES (1,'General Health','General health information and preventive care','2026-10-23 05:14:03'),(2,'Women Health','Health information focused on women','2026-10-23 05:14:03'),(3,'Menstrual Health','Menstrual cycle and period health','2026-10-23 05:14:03'),(4,'Reproductive Health','Reproductive and sexual health education','2026-10-23 05:14:03'),(5,'Nutrition','Healthy diet and nutrition guidance','2026-10-23 05:14:03');
/*!40000 ALTER TABLE `article_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `camp_organizers`
--

DROP TABLE IF EXISTS `camp_organizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `camp_organizers` (
  `organizer_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `organization_name` varchar(200) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`organizer_id`),
  KEY `fk_organizer_user` (`user_id`),
  KEY `idx_organizer_name` (`organization_name`),
  CONSTRAINT `fk_organizer_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `camp_organizers`
--

LOCK TABLES `camp_organizers` WRITE;
/*!40000 ALTER TABLE `camp_organizers` DISABLE KEYS */;
/*!40000 ALTER TABLE `camp_organizers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `camp_registrations`
--

DROP TABLE IF EXISTS `camp_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `camp_registrations` (
  `registration_id` int NOT NULL AUTO_INCREMENT,
  `camp_id` int NOT NULL,
  `user_id` int NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `participants_count` int NOT NULL DEFAULT '1',
  `status` enum('registered','confirmed','attended','cancelled','no_show') NOT NULL DEFAULT 'registered',
  `notes` text,
  PRIMARY KEY (`registration_id`),
  UNIQUE KEY `uq_camp_user` (`camp_id`,`user_id`),
  KEY `fk_registration_user` (`user_id`),
  KEY `idx_registration_status` (`status`),
  CONSTRAINT `fk_registration_camp` FOREIGN KEY (`camp_id`) REFERENCES `medical_camps` (`camp_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_registration_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_participants_count` CHECK ((`participants_count` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `camp_registrations`
--

LOCK TABLES `camp_registrations` WRITE;
/*!40000 ALTER TABLE `camp_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `camp_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `subject` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `status` enum('new','in_progress','resolved','closed') NOT NULL DEFAULT 'new',
  `admin_reply` text,
  `replied_by` int DEFAULT NULL,
  `replied_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `fk_contact_user` (`user_id`),
  KEY `fk_contact_admin` (`replied_by`),
  KEY `idx_contact_status` (`status`),
  KEY `idx_contact_created` (`created_at`),
  CONSTRAINT `fk_contact_admin` FOREIGN KEY (`replied_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_contact_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES (1,NULL,'Example','example@gmail.com','9559343983','general','General Enquiry','new',NULL,NULL,NULL,'2026-10-23 04:54:06');
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facility_reviews`
--

DROP TABLE IF EXISTS `facility_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facility_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `facility_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `review_text` text,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uq_facility_review_user` (`facility_id`,`user_id`),
  KEY `fk_review_user` (`user_id`),
  KEY `idx_review_status` (`status`),
  CONSTRAINT `fk_review_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_review_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facility_reviews`
--

LOCK TABLES `facility_reviews` WRITE;
/*!40000 ALTER TABLE `facility_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `facility_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facility_services`
--

DROP TABLE IF EXISTS `facility_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facility_services` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `facility_id` int NOT NULL,
  `service_name` varchar(150) NOT NULL,
  `description` text,
  `fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`),
  UNIQUE KEY `uq_facility_service` (`facility_id`,`service_name`),
  CONSTRAINT `fk_service_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facility_services`
--

LOCK TABLES `facility_services` WRITE;
/*!40000 ALTER TABLE `facility_services` DISABLE KEYS */;
/*!40000 ALTER TABLE `facility_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_articles`
--

DROP TABLE IF EXISTS `health_articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_articles` (
  `article_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(250) NOT NULL,
  `slug` varchar(280) NOT NULL,
  `summary` text,
  `content` longtext NOT NULL,
  `category_id` int DEFAULT NULL,
  `author_id` int DEFAULT NULL,
  `featured_image` varchar(500) DEFAULT NULL,
  `language` varchar(50) NOT NULL DEFAULT 'English',
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`article_id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `fk_article_category` (`category_id`),
  KEY `fk_article_author` (`author_id`),
  KEY `idx_article_status` (`status`),
  KEY `idx_article_published` (`published_at`),
  CONSTRAINT `fk_article_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_article_category` FOREIGN KEY (`category_id`) REFERENCES `article_categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_articles`
--

LOCK TABLES `health_articles` WRITE;
/*!40000 ALTER TABLE `health_articles` DISABLE KEYS */;
/*!40000 ALTER TABLE `health_articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_awareness_events`
--

DROP TABLE IF EXISTS `health_awareness_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_awareness_events` (
  `event_id` int NOT NULL AUTO_INCREMENT,
  `event_name` varchar(200) NOT NULL,
  `description` text,
  `topic` varchar(150) DEFAULT NULL,
  `organizer_id` int DEFAULT NULL,
  `facility_id` int DEFAULT NULL,
  `event_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `venue` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `registration_required` tinyint(1) NOT NULL DEFAULT '0',
  `max_participants` int DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `status` enum('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  KEY `fk_event_organizer` (`organizer_id`),
  KEY `fk_event_facility` (`facility_id`),
  KEY `idx_event_date` (`event_date`),
  KEY `idx_event_city` (`city`),
  CONSTRAINT `fk_event_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_event_organizer` FOREIGN KEY (`organizer_id`) REFERENCES `camp_organizers` (`organizer_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_awareness_events`
--

LOCK TABLES `health_awareness_events` WRITE;
/*!40000 ALTER TABLE `health_awareness_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `health_awareness_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `healthcare_facilities`
--

DROP TABLE IF EXISTS `healthcare_facilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `healthcare_facilities` (
  `facility_id` int NOT NULL AUTO_INCREMENT,
  `facility_name` varchar(200) NOT NULL,
  `facility_type` enum('hospital','clinic','phc','diagnostic_center','pharmacy','other') NOT NULL DEFAULT 'clinic',
  `description` text,
  `address` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `opening_hours` varchar(255) DEFAULT NULL,
  `emergency_services` tinyint(1) NOT NULL DEFAULT '0',
  `image_url` varchar(500) DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`facility_id`),
  KEY `fk_facility_creator` (`created_by`),
  KEY `idx_facility_city` (`city`),
  KEY `idx_facility_type` (`facility_type`),
  KEY `idx_facility_verification` (`verification_status`),
  CONSTRAINT `fk_facility_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `healthcare_facilities`
--

LOCK TABLES `healthcare_facilities` WRITE;
/*!40000 ALTER TABLE `healthcare_facilities` DISABLE KEYS */;
INSERT INTO `healthcare_facilities` VALUES (1,'SehatSetu Demo Hospital','hospital','Demo listing for general healthcare services.','Demo Address, Gomti Nagar','Lucknow','Uttar Pradesh','226010',NULL,NULL,'0000000000','demo-hospital@example.com',NULL,'9:00 AM - 5:00 PM',0,NULL,'verified',NULL,'2026-10-23 04:21:18','2026-10-23 04:21:18'),(2,'SehatSetu Demo Clinic','clinic','Demo listing for general consultation.','Demo Address, Aliganj','Lucknow','Uttar Pradesh','226024',NULL,NULL,'0000000001','demo-clinic@example.com',NULL,'10:00 AM - 6:00 PM',0,NULL,'verified',NULL,'2026-10-23 04:21:18','2026-10-23 04:21:18'),(3,'SehatSetu Demo Health Centre','phc','Demo listing for primary healthcare services.','Demo Address, Indira Nagar','Lucknow','Uttar Pradesh','226016',NULL,NULL,'0000000002','demo-health@example.com',NULL,'9:00 AM - 4:00 PM',0,NULL,'verified',NULL,'2026-10-23 04:21:18','2026-10-23 04:21:18');
/*!40000 ALTER TABLE `healthcare_facilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_camps`
--

DROP TABLE IF EXISTS `medical_camps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_camps` (
  `camp_id` int NOT NULL AUTO_INCREMENT,
  `camp_name` varchar(200) NOT NULL,
  `description` text,
  `camp_type` varchar(100) DEFAULT NULL,
  `organizer_id` int DEFAULT NULL,
  `facility_id` int DEFAULT NULL,
  `camp_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `address` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `registration_deadline` date DEFAULT NULL,
  `max_participants` int DEFAULT NULL,
  `is_free` tinyint(1) NOT NULL DEFAULT '1',
  `registration_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `contact_phone` varchar(20) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `status` enum('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`camp_id`),
  KEY `fk_camp_organizer` (`organizer_id`),
  KEY `fk_camp_facility` (`facility_id`),
  KEY `idx_camp_date` (`camp_date`),
  KEY `idx_camp_city` (`city`),
  KEY `idx_camp_status` (`status`),
  CONSTRAINT `fk_camp_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_camp_organizer` FOREIGN KEY (`organizer_id`) REFERENCES `camp_organizers` (`organizer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_camp_capacity` CHECK (((`max_participants` is null) or (`max_participants` > 0)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_camps`
--

LOCK TABLES `medical_camps` WRITE;
/*!40000 ALTER TABLE `medical_camps` DISABLE KEYS */;
INSERT INTO `medical_camps` VALUES (1,'SehatSetu Demo General Health Camp','Demo camp for general health check-ups.','General Health',NULL,NULL,'2026-12-10','09:00:00','14:00:00','Demo Address, Gomti Nagar','Lucknow','Uttar Pradesh','226010',NULL,NULL,1,0.00,'0000000000',NULL,'upcoming','2026-10-23 04:31:09'),(2,'SehatSetu Demo Eye Check-up Camp','Demo camp for basic eye check-ups.','Eye Check-up',NULL,NULL,'2026-12-15','10:00:00','15:00:00','Demo Address, Aliganj','Lucknow','Uttar Pradesh','226024',NULL,NULL,1,0.00,'0000000001',NULL,'upcoming','2026-10-23 04:31:09'),(3,'SehatSetu Demo Women Health Camp','Demo camp for general women health awareness.','Women Health',NULL,NULL,'2026-12-20','09:00:00','13:00:00','Demo Address, Indira Nagar','Lucknow','Uttar Pradesh','226016',NULL,NULL,1,0.00,'0000000002',NULL,'upcoming','2026-10-23 04:31:09');
/*!40000 ALTER TABLE `medical_camps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `notification_type` enum('general','camp','health_article','facility','system') NOT NULL DEFAULT 'general',
  `related_id` int DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_notification_user_read` (`user_id`,`is_read`),
  KEY `idx_notification_created` (`created_at`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
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
-- Table structure for table `provider_availability`
--

DROP TABLE IF EXISTS `provider_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_availability` (
  `availability_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `consultation_mode` enum('in_person','online','both') NOT NULL DEFAULT 'in_person',
  PRIMARY KEY (`availability_id`),
  UNIQUE KEY `uq_provider_schedule` (`provider_id`,`day_of_week`,`start_time`,`end_time`),
  CONSTRAINT `fk_availability_provider` FOREIGN KEY (`provider_id`) REFERENCES `provider_profiles` (`provider_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_availability_time` CHECK ((`end_time` > `start_time`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_availability`
--

LOCK TABLES `provider_availability` WRITE;
/*!40000 ALTER TABLE `provider_availability` DISABLE KEYS */;
/*!40000 ALTER TABLE `provider_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `provider_profiles`
--

DROP TABLE IF EXISTS `provider_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_profiles` (
  `provider_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `facility_id` int DEFAULT NULL,
  `provider_type` enum('doctor','nurse','specialist','health_worker','other') NOT NULL DEFAULT 'doctor',
  `specialization` varchar(150) DEFAULT NULL,
  `qualification` varchar(200) DEFAULT NULL,
  `registration_number` varchar(100) DEFAULT NULL,
  `experience_years` int NOT NULL DEFAULT '0',
  `consultation_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `bio` text,
  `verification_status` enum('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`provider_id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `registration_number` (`registration_number`),
  KEY `fk_provider_facility` (`facility_id`),
  KEY `idx_provider_specialization` (`specialization`),
  CONSTRAINT `fk_provider_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_provider_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_provider_experience` CHECK ((`experience_years` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_profiles`
--

LOCK TABLES `provider_profiles` WRITE;
/*!40000 ALTER TABLE `provider_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `provider_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_favorites`
--

DROP TABLE IF EXISTS `user_favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favorites` (
  `favorite_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `facility_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`favorite_id`),
  UNIQUE KEY `uq_user_favorite` (`user_id`,`facility_id`),
  KEY `fk_favorite_facility` (`facility_id`),
  CONSTRAINT `fk_favorite_facility` FOREIGN KEY (`facility_id`) REFERENCES `healthcare_facilities` (`facility_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_favorites`
--

LOCK TABLES `user_favorites` WRITE;
/*!40000 ALTER TABLE `user_favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('patient','provider','admin') NOT NULL DEFAULT 'patient',
  `profile_image` varchar(500) DEFAULT NULL,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@gmail.com',NULL,'scrypt:32768:8:1$gCS45gTkT5C6zzLg$5e4469893d8ba1c783029a322659be7952cf54523e65e197fabfc098ed15040774e8a3ad00efd4b6245ed9fdd9012fd5b436d8d565d962100bd295a84e19ab10','admin',NULL,NULL,NULL,NULL,NULL,1,0,'2026-10-20 17:42:45','2026-10-20 17:42:45'),(2,'Rishu Mishra','mishrarishu2323@gmail.com','9559343983','scrypt:32768:8:1$H0lMK83KP2195LCI$220b0ccbe6ce26b41943f36912227cd2f2a5718489ccfda4facb044f7fe61c6d97add3ae7b23183bf3eb985b2cf1f564ecf4bdd616d9c9604d7a955209ab0d63','patient',NULL,NULL,NULL,NULL,NULL,1,0,'2026-10-22 18:26:57','2026-10-22 18:26:57');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'sehatsetu_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-23 20:09:10
