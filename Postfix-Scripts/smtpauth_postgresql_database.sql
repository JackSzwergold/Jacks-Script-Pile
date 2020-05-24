-- $Id: smtpauth_postgresql_database.sql 1119 2005-02-28 09:03:09Z patrick $
--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1245 (class 0 OID 0)
-- Name: DUMP TIMESTAMP; Type: DUMP TIMESTAMP; Schema: -; Owner: 
--

-- Started on 2005-02-28 09:16:53 Westeuropäische Normalzeit


--
-- TOC entry 1247 (class 1262 OID 25176)
-- Name: mail; Type: DATABASE; Schema: -; Owner: root
--

CREATE DATABASE mail WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII';


ALTER DATABASE mail OWNER TO root;

\connect mail

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1248 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public namespace';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1039 (class 1259 OID 25177)
-- Dependencies: 1241 3
-- Name: users; Type: TABLE; Schema: public; Owner: root; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255),
    userrealm character varying(255),
    userpassword character varying(255),
    auth smallint DEFAULT 0
);


ALTER TABLE public.users OWNER TO root;

--
-- TOC entry 1250 (class 0 OID 0)
-- Dependencies: 1039
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: root
--

COMMENT ON TABLE users IS 'mail users';


--
-- TOC entry 1244 (class 0 OID 25177)
-- Dependencies: 1039
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO users (id, username, userrealm, userpassword, auth) VALUES (1, 'test', 'mail.example.com', 'testpass', 1);


--
-- TOC entry 1243 (class 16386 OID 25181)
-- Dependencies: 1039 1039
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: root; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT id PRIMARY KEY (id);


ALTER INDEX public.id OWNER TO root;

--
-- TOC entry 1252 (class 0 OID 0)
-- Name: DUMP TIMESTAMP; Type: DUMP TIMESTAMP; Schema: -; Owner: 
--

-- Completed on 2005-02-28 09:16:53 Westeuropäische Normalzeit


--
-- TOC entry 1249 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 1251 (class 0 OID 0)
-- Dependencies: 1039
-- Name: users; Type: ACL; Schema: public; Owner: root
--

REVOKE ALL ON TABLE users FROM PUBLIC;
GRANT SELECT,UPDATE ON TABLE users TO postfix;


