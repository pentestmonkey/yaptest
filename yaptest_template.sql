--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: app_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE app_protocols (
    id serial primary key NOT NULL,
    name character varying(100) NOT NULL,
    amap_name character varying(100),
    nmap_name character varying(100)
);



--
-- Name: app_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('app_protocols', 'id'), 1, false);


--
-- Name: command_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--
CREATE TABLE command_log (
    id serial primary key NOT NULL,
    "time" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    command text NOT NULL,
    command_status_id integer NOT NULL
);


ALTER TABLE public.command_log OWNER TO postgres;

--
-- Name: command_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('command_log', 'id'), 1, false);


--
-- Name: command_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE command_status (
    id serial primary key NOT NULL,
    name character varying(15) NOT NULL
);


ALTER TABLE public.command_status OWNER TO postgres;

--
-- Name: command_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('command_status', 'id'), 1, false);


--
-- Name: commands; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE commands (
    id serial primary key NOT NULL,
    name text NOT NULL,
    hash text
);


ALTER TABLE public.commands OWNER TO postgres;

--
-- Name: commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('commands', 'id'), 1, false);


--
-- Name: credential_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE credential_types (
    id serial primary key NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.credential_types OWNER TO postgres;

--
-- Name: credential_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('credential_types', 'id'), 1, false);


--
-- Name: credentials; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE credentials (
    id serial primary key NOT NULL,
    uid integer,
    host_id integer NOT NULL,
    port_id integer,
    credential_type_id integer NOT NULL,
    "domain" character varying(30),
    username character varying(100),
    "password" character varying(20),
    password_hash character varying(100),
    password_hash_type_id integer,
    password_half1 character varying(7),
    password_half2 character varying(7),
    hash_half1 character varying(16),
    hash_half2 character varying(16),
    "group" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.credentials OWNER TO postgres;

--
-- Name: credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('credentials', 'id'), 1, false);


--
-- Name: custom_entities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE custom_entities (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.custom_entities OWNER TO postgres;

--
-- Name: custom_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('custom_entities', 'id'), 1, false);


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE group_memberships (
    id serial primary key NOT NULL,
    group_id integer NOT NULL,
    member_id integer NOT NULL
);


ALTER TABLE public.group_memberships OWNER TO postgres;

--
-- Name: group_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('group_memberships', 'id'), 1, false);


--
-- Name: host_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE host_info (
    id serial primary key NOT NULL,
    host_id integer NOT NULL,
    host_key_id integer NOT NULL,
    value text
);


ALTER TABLE public.host_info OWNER TO postgres;

--
-- Name: host_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('host_info', 'id'), 1, false);


--
-- Name: host_keys; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE host_keys (
    id serial primary key NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.host_keys OWNER TO postgres;

--
-- Name: host_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('host_keys', 'id'), 1, false);


--
-- Name: host_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE host_progress (
    id serial primary key NOT NULL,
    host_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);


ALTER TABLE public.host_progress OWNER TO postgres;

--
-- Name: host_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('host_progress', 'id'), 1, false);


--
-- Name: hostname_types; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE hostname_types (
    id serial primary key NOT NULL,
    name_type character varying(100) NOT NULL
);



--
-- Name: hostname_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('hostname_types', 'id'), 1, false);


--
-- Name: hostnames; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE hostnames (
    id serial primary key NOT NULL,
    name_type integer NOT NULL,
    name text NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: hostnames_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('hostnames', 'id'), 1, false);


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE hosts (
    id serial primary key NOT NULL,
    ip_address inet NOT NULL,
    test_area_id integer NOT NULL
);



--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('hosts', 'id'), 79, true);


--
-- Name: hosts_to_mac_addresses; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE hosts_to_mac_addresses (
    id serial primary key NOT NULL,
    mac_address_id integer NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: hosts_to_mac_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('hosts_to_mac_addresses', 'id'), 39, true);


--
-- Name: icmp; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE icmp (
    id serial primary key NOT NULL,
    icmp_type smallint NOT NULL,
    icmp_code smallint NOT NULL,
    host_id integer NOT NULL
);


ALTER TABLE public.icmp OWNER TO postgres;

--
-- Name: icmp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('icmp', 'id'), 34, true);


--
-- Name: icmp_names; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE icmp_names (
    id serial primary key NOT NULL,
    icmp_type smallint NOT NULL,
    icmp_code smallint NOT NULL,
    name character varying(255)
);


ALTER TABLE public.icmp_names OWNER TO postgres;

--
-- Name: icmp_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('icmp_names', 'id'), 8, true);


--
-- Name: issue_ratings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issue_ratings (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.issue_ratings OWNER TO postgres;

--
-- Name: issue_ratings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issue_ratings', 'id'), 3, true);


--
-- Name: issue_sources; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issue_sources (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.issue_sources OWNER TO postgres;

--
-- Name: issue_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issue_sources', 'id'), 1, true);


--
-- Name: issues; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issues (
    id serial primary key NOT NULL,
    shortname character varying(60),
    title text,
    description text,
    rating integer,
    source integer
);


ALTER TABLE public.issues OWNER TO postgres;

--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issues', 'id'), 2, true);


--
-- Name: issues_to_custom_entities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issues_to_custom_entities (
    id serial primary key NOT NULL,
    issue_id integer NOT NULL,
    entity_id integer NOT NULL
);


ALTER TABLE public.issues_to_custom_entities OWNER TO postgres;

--
-- Name: issues_to_custom_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issues_to_custom_entities', 'id'), 1, false);


--
-- Name: issues_to_hosts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issues_to_hosts (
    id serial primary key NOT NULL,
    issue_id integer NOT NULL,
    host_id integer NOT NULL
);


ALTER TABLE public.issues_to_hosts OWNER TO postgres;

--
-- Name: issues_to_hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issues_to_hosts', 'id'), 1, false);


--
-- Name: issues_to_ports; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issues_to_ports (
    id serial primary key NOT NULL,
    issue_id integer NOT NULL,
    port_id integer NOT NULL
);


ALTER TABLE public.issues_to_ports OWNER TO postgres;

--
-- Name: issues_to_ports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issues_to_ports', 'id'), 1, false);


--
-- Name: issues_to_testareas; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE issues_to_testareas (
    id serial primary key NOT NULL,
    issue_id integer NOT NULL,
    testarea_id integer NOT NULL
);


ALTER TABLE public.issues_to_testareas OWNER TO postgres;

--
-- Name: issues_to_testareas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('issues_to_testareas', 'id'), 1, false);


--
-- Name: mac_addresses; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE mac_addresses (
    id serial primary key NOT NULL,
    mac_address macaddr NOT NULL
);



--
-- Name: mac_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('mac_addresses', 'id'), 52, true);


--
-- Name: password_hash_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE password_hash_types (
    id serial primary key NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.password_hash_types OWNER TO postgres;

--
-- Name: password_hash_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('password_hash_types', 'id'), 1, false);


--
-- Name: password_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE password_types (
    id serial primary key NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.password_types OWNER TO postgres;

--
-- Name: password_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('password_types', 'id'), 1, true);


--
-- Name: port_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE port_info (
    id serial primary key NOT NULL,
    port_id integer,
    key_id integer NOT NULL,
    value text
);


ALTER TABLE public.port_info OWNER TO postgres;

--
-- Name: port_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('port_info', 'id'), 1, false);


--
-- Name: port_keys; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE port_keys (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.port_keys OWNER TO postgres;

--
-- Name: port_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('port_keys', 'id'), 4, true);


--
-- Name: port_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE port_progress (
    id serial primary key NOT NULL,
    port_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);


ALTER TABLE public.port_progress OWNER TO postgres;

--
-- Name: port_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('port_progress', 'id'), 1, false);


--
-- Name: ports; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE ports (
    id serial primary key NOT NULL,
    transport_protocol_id integer NOT NULL,
    port integer NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: ports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('ports', 'id'), 311, true);


--
-- Name: ports_to_app_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE ports_to_app_protocols (
    id serial primary key NOT NULL,
    port_id integer NOT NULL,
    app_protocol_id integer NOT NULL,
    layer_no integer NOT NULL
);



--
-- Name: ports_to_app_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('ports_to_app_protocols', 'id'), 1, false);


--
-- Name: progress_states; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE progress_states (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.progress_states OWNER TO postgres;

--
-- Name: progress_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('progress_states', 'id'), 1, false);


--
-- Name: test_areas; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE test_areas (
    id serial primary key NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.test_areas OWNER TO postgres;
grant insert, select, update, delete on test_areas to yaptest_user;

--
-- Name: test_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--
SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('test_areas', 'id'), 1, false);

--
-- Name: transport_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
--

CREATE TABLE transport_protocols (
    id serial primary key NOT NULL,
    name character varying(10) NOT NULL
);



--
-- Name: transport_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest_user
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('transport_protocols', 'id'), 2, true);


--
-- Name: view_command_log; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_command_log AS
    SELECT command_log."time", command_log.command, command_status.name AS status FROM (command_log JOIN command_status ON ((command_log.command_status_id = command_status.id)));


ALTER TABLE public.view_command_log OWNER TO postgres;

--
-- Name: view_credentials; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_credentials AS
    SELECT test_areas.name AS test_area_name, test_areas.id AS test_area_id, credential_types.name AS credential_type_name, hosts.ip_address, hosts.id AS host_id, ports.port, transport_protocols.name AS transport_protocol_name, ports.id AS port_id, transport_protocols.id AS transport_protocol_id, credentials."domain", credentials.uid, credentials.username, credentials."password", credentials.password_hash, password_hash_types.name AS password_hash_type_name FROM ((((((credentials JOIN hosts ON ((credentials.host_id = hosts.id))) JOIN credential_types ON ((credentials.credential_type_id = credential_types.id))) JOIN test_areas ON ((hosts.test_area_id = test_areas.id))) LEFT JOIN password_hash_types ON ((credentials.password_hash_type_id = password_hash_types.id))) LEFT JOIN ports ON ((credentials.port_id = ports.id))) LEFT JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id))) WHERE (credentials."group" IS FALSE) ORDER BY hosts.ip_address, ports.port, transport_protocols.name, credential_types.name, credentials."domain", password_hash_types.name, credentials.username, credentials."password";


ALTER TABLE public.view_credentials OWNER TO postgres;

create or replace view view_host_info as 
 SELECT test_areas.name AS test_area_name, test_areas.id AS test_area_id, hosts.id AS host_id, host_info.id as host_info_id, host_key_id, hosts.ip_address, host_keys.name AS "key", host_info.value
   FROM hosts
   JOIN test_areas ON hosts.test_area_id = test_areas.id
   JOIN host_info ON host_info.host_id = hosts.id
   JOIN host_keys ON host_info.host_key_id = host_keys.id
  ORDER BY test_areas.name, hosts.ip_address;
grant select on view_host_info to yaptest_user;

-- create view view_host_info as SELECT test_areas.name AS test_area_name, test_areas.id AS test_area_id, hosts.id AS host_id, hosts.ip_address, host_keys.name AS "key", host_info.value FROM hosts JOIN test_areas ON hosts.test_area_id = test_areas.id JOIN host_info ON host_info.host_id = hosts.id JOIN host_keys ON host_info.host_key_id = host_keys.id ORDER BY test_areas.name, hosts.ip_address;

--
-- Name: view_host_info; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE view_host_info FROM PUBLIC;
REVOKE ALL ON TABLE view_host_info FROM postgres;
GRANT ALL ON TABLE view_host_info TO postgres;
GRANT SELECT ON TABLE view_host_info TO yaptest_user;

create view view_host_issues as SELECT issues_to_hosts.id, test_areas.name AS test_area_name, hosts.ip_address, issues.shortname AS issue
   FROM issues_to_hosts
      JOIN hosts ON hosts.id = issues_to_hosts.host_id
         JOIN issues ON issues_to_hosts.issue_id = issues.id
	    JOIN test_areas ON hosts.test_area_id = test_areas.id
	      ORDER BY test_areas.name, hosts.ip_address, issues.shortname;

--
-- Name: view_host_issues; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE view_host_issues FROM PUBLIC;
REVOKE ALL ON TABLE view_host_issues FROM postgres;
GRANT ALL ON TABLE view_host_issues TO postgres;
GRANT SELECT ON TABLE view_host_issues TO yaptest_user;


--
-- Name: view_host_progress; Type: ACL; Schema: public; Owner: postgres
--
create view view_host_progress as SELECT hosts.id AS host_id, test_areas.name AS test_area_name, hosts.ip_address, commands.name AS command, progress_states.name AS state
   FROM host_progress
      JOIN hosts ON host_progress.host_id = hosts.id
         JOIN commands ON host_progress.command_id = commands.id
	    JOIN progress_states ON progress_states.id = host_progress.state_id
	       JOIN test_areas ON hosts.test_area_id = test_areas.id
	         ORDER BY test_areas.name, commands.name, hosts.ip_address;

REVOKE ALL ON TABLE view_host_progress FROM PUBLIC;
REVOKE ALL ON TABLE view_host_progress FROM postgres;
GRANT ALL ON TABLE view_host_progress TO postgres;
GRANT SELECT ON TABLE view_host_progress TO yaptest_user;


--
-- Name: view_hosts; Type: ACL; Schema: public; Owner: postgres
--
create view view_hosts as SELECT hosts.id AS host_id, test_areas.id AS test_area_id, test_areas.name AS test_area_name, hosts.ip_address, hostnames.name AS hostname, hostname_types.name_type
   FROM hosts
      JOIN test_areas ON hosts.test_area_id = test_areas.id
         LEFT JOIN hostnames ON hostnames.host_id = hosts.id
	    LEFT JOIN hostname_types ON hostname_types.id = hostnames.name_type
	      ORDER BY test_areas.name, hosts.ip_address, hostname_types.name_type;


REVOKE ALL ON TABLE view_hosts FROM PUBLIC;
REVOKE ALL ON TABLE view_hosts FROM postgres;
GRANT ALL ON TABLE view_hosts TO postgres;
GRANT SELECT ON TABLE view_hosts TO yaptest_user;


--
-- Name: view_port_info; Type: ACL; Schema: public; Owner: postgres
--
create view view_port_info as SELECT port_info.id as port_info_id, ports.id AS port_id, hosts.id AS host_id, hosts.ip_address, hosts.test_area_id, test_areas.name AS test_area_name, ports.port, transport_protocols.name AS transport_protocol, port_keys.name AS port_info_key, port_info.value
   FROM port_info
      JOIN port_keys ON port_info.key_id = port_keys.id
         JOIN ports ON port_info.port_id = ports.id
	    JOIN hosts ON ports.host_id = hosts.id
	       JOIN transport_protocols ON ports.transport_protocol_id = transport_protocols.id
	          JOIN test_areas ON hosts.test_area_id = test_areas.id
		    ORDER BY hosts.ip_address, ports.port, transport_protocols.name, port_keys.name;
REVOKE ALL ON TABLE view_port_info FROM PUBLIC;
REVOKE ALL ON TABLE view_port_info FROM postgres;
GRANT ALL ON TABLE view_port_info TO postgres;
GRANT SELECT ON TABLE view_port_info TO yaptest_user;


--
-- Name: view_http_banners; Type: ACL; Schema: public; Owner: postgres
--
create view view_http_banners as SELECT view_port_info.ip_address, view_port_info.port, view_port_info.transport_protocol, view_port_info.port_info_key, view_port_info.value
   FROM view_port_info
     WHERE (view_port_info.port IN ( SELECT DISTINCT view_port_info.port
                FROM view_port_info
		          WHERE view_port_info.port_info_key = 'nmap_service_name'::text AND view_port_info.value = 'http'::text
			            ORDER BY view_port_info.port)) AND view_port_info.port_info_key = 'nmap_service_version'::text;
REVOKE ALL ON TABLE view_http_banners FROM PUBLIC;
REVOKE ALL ON TABLE view_http_banners FROM postgres;
GRANT ALL ON TABLE view_http_banners TO postgres;
GRANT SELECT ON TABLE view_http_banners TO yaptest_user;


--
-- Name: view_icmp; Type: ACL; Schema: public; Owner: postgres
--
create view view_icmp as SELECT test_areas.name AS test_area_name, test_areas.id AS test_area_id, hosts.ip_address, icmp.host_id, icmp.icmp_type, icmp.icmp_code, icmp_names.name AS icmp_name FROM icmp JOIN icmp_names ON icmp.icmp_type = icmp_names.icmp_type AND icmp.icmp_code = icmp_names.icmp_code JOIN hosts ON icmp.host_id = hosts.id JOIN test_areas ON hosts.test_area_id = test_areas.id;
REVOKE ALL ON view_icmp FROM PUBLIC;
REVOKE ALL ON view_icmp FROM postgres;
GRANT ALL ON view_icmp TO postgres;
GRANT SELECT ON view_icmp TO yaptest_user;


--
-- Name: view_os; Type: ACL; Schema: public; Owner: postgres
--
create view view_os as SELECT test_areas.name, hosts.ip_address, host_info.value
   FROM hosts
      JOIN test_areas ON hosts.test_area_id = test_areas.id
         LEFT JOIN host_info ON host_info.host_id = hosts.id
	    LEFT JOIN host_keys ON host_info.host_key_id = host_keys.id
	      WHERE host_keys.name IS NULL OR host_keys.name::text = 'os'::text
	        ORDER BY test_areas.name, hosts.ip_address;

REVOKE ALL ON TABLE view_os FROM PUBLIC;
REVOKE ALL ON TABLE view_os FROM postgres;
GRANT ALL ON TABLE view_os TO postgres;
GRANT SELECT ON TABLE view_os TO yaptest_user;


--
-- Name: view_port_info_ssl; Type: ACL; Schema: public; Owner: postgres
--
create view view_port_info_ssl as SELECT view_port_info.port_info_id, view_port_info.port_id, view_port_info.host_id, view_port_info.ip_address, view_port_info.test_area_id, view_port_info.test_area_name, view_port_info.port, view_port_info.transport_protocol, view_port_info.port_info_key, view_port_info.value, v2.value AS nmap_service_tunnel FROM view_port_info LEFT JOIN view_port_info v2 ON view_port_info.port_id = v2.port_id AND (v2.port_info_key = 'amap_service_tunnel'::text or v2.port_info_key = 'nmap_service_tunnel'::text) WHERE view_port_info.port_info_key <> 'nmap_service_tunnel'::text and view_port_info.port_info_key <> 'amap_service_tunnel'::text;

REVOKE ALL ON TABLE view_port_info_ssl FROM PUBLIC;
REVOKE ALL ON TABLE view_port_info_ssl FROM postgres;
GRANT ALL ON TABLE view_port_info_ssl TO postgres;
GRANT SELECT ON TABLE view_port_info_ssl TO yaptest_user;


--
-- Name: view_port_issues; Type: ACL; Schema: public; Owner: postgres
--
create view view_port_issues as SELECT issues_to_ports.id, test_areas.name AS test_area_name, hosts.ip_address, ports.port, transport_protocols.name AS transport_protocol_name, issues.shortname AS issue
   FROM issues_to_ports
      JOIN ports ON ports.id = issues_to_ports.port_id
         JOIN transport_protocols ON ports.transport_protocol_id = transport_protocols.id
	    JOIN hosts ON ports.host_id = hosts.id
	       JOIN issues ON issues_to_ports.issue_id = issues.id
	          JOIN test_areas ON hosts.test_area_id = test_areas.id
		    ORDER BY test_areas.name, hosts.ip_address, issues.shortname;
REVOKE ALL ON TABLE view_port_issues FROM PUBLIC;
REVOKE ALL ON TABLE view_port_issues FROM postgres;
GRANT ALL ON TABLE view_port_issues TO postgres;
GRANT SELECT ON TABLE view_port_issues TO yaptest_user;


--
-- Name: view_port_progress; Type: ACL; Schema: public; Owner: postgres
--
create view view_port_progress as SELECT ports.id AS port_id, hosts.ip_address, hosts.test_area_id, ports.port, test_areas.name AS test_area_name, transport_protocols.name AS transport_protocol_name, commands.name AS command, progress_states.name AS state
   FROM port_progress
      JOIN ports ON port_progress.port_id = ports.id
         JOIN commands ON port_progress.command_id = commands.id
	    JOIN progress_states ON progress_states.id = port_progress.state_id
	       JOIN hosts ON hosts.id = ports.host_id
	          JOIN transport_protocols ON ports.transport_protocol_id = transport_protocols.id
		     JOIN test_areas ON hosts.test_area_id = test_areas.id
		       ORDER BY test_areas.name, commands.name, hosts.ip_address, ports.port, transport_protocols.name;

REVOKE ALL ON TABLE view_port_progress FROM PUBLIC;
REVOKE ALL ON TABLE view_port_progress FROM postgres;
GRANT ALL ON TABLE view_port_progress TO postgres;
GRANT SELECT ON TABLE view_port_progress TO yaptest_user;


--
-- Name: view_ports; Type: ACL; Schema: public; Owner: postgres
--
create view view_ports as SELECT ports.id AS port_id, hosts.id AS host_id, hosts.ip_address, hosts.test_area_id, ports.port, test_areas.name AS test_area_name, transport_protocols.name AS transport_protocol
   FROM hosts
      JOIN ports ON hosts.id = ports.host_id
         JOIN transport_protocols ON ports.transport_protocol_id = transport_protocols.id
	    JOIN test_areas ON hosts.test_area_id = test_areas.id
	      ORDER BY hosts.ip_address, transport_protocols.name, ports.port;


REVOKE ALL ON TABLE view_ports FROM PUBLIC;
REVOKE ALL ON TABLE view_ports FROM postgres;
GRANT ALL ON TABLE view_ports TO postgres;
GRANT SELECT ON TABLE view_ports TO yaptest_user;


--
-- Name: view_ssh_banners; Type: ACL; Schema: public; Owner: postgres
--
create view view_ssh_banners as  SELECT view_port_info.ip_address, view_port_info.port, view_port_info.transport_protocol, view_port_info.port_info_key, view_port_info.value
   FROM view_port_info
     WHERE view_port_info.port_info_key = 'nmap_service_version'::text AND ((view_port_info.ip_address, view_port_info.port, view_port_info.transport_protocol) IN ( SELECT view_port_info.ip_address, view_port_info.port, view_port_info.transport_protocol
                FROM view_port_info
		          WHERE view_port_info.port_info_key = 'nmap_service_name'::text AND view_port_info.value = 'ssh'::text));

REVOKE ALL ON TABLE view_ssh_banners FROM PUBLIC;
REVOKE ALL ON TABLE view_ssh_banners FROM postgres;
GRANT ALL ON TABLE view_ssh_banners TO postgres;
GRANT SELECT ON TABLE view_ssh_banners TO yaptest_user;


--
-- PostgreSQL database dump complete
--

grant select,update,delete,insert on hosts to yaptest_user;
grant select,update,delete,insert on app_protocols to yaptest_user;
grant select,update,delete,insert on hostname_types to yaptest_user;
grant select,update,delete,insert on hostnames to yaptest_user;
grant select,update,delete,insert on hosts_to_mac_addresses to yaptest_user;
grant select,update,delete,insert on mac_addresses to yaptest_user;
grant select,update,delete,insert on ports to yaptest_user;
grant select,update,delete,insert on ports_to_app_protocols to yaptest_user;
grant select,update,delete,insert on transport_protocols to yaptest_user;

create or replace view view_port_summary as SELECT count(1) AS count, view_ports.port, view_ports.transport_protocol, view_ports.test_area_id, view_ports.test_area_name FROM view_ports GROUP BY view_ports.port, view_ports.transport_protocol, view_ports.test_area_id, view_ports.test_area_name ORDER BY count(1) DESC, view_ports.port, view_ports.transport_protocol;

create view view_port_summary_by_test_area as select count(1), test_area_id, test_area_name, port, transport_protocol from view_ports group by test_area_id, test_area_name, port, transport_protocol order by test_area_id, port desc, transport_protocol desc;

grant select on view_port_summary_by_test_area to yaptest_user;

grant select on view_port_summary to yaptest_user;

create view view_password_hashes as SELECT test_area_id, view_credentials.host_id, view_credentials.test_area_name, view_credentials.credential_type_name, view_credentials.ip_address, view_credentials.port, view_credentials.transport_protocol_name, view_credentials.username, view_credentials."password", view_credentials.password_hash, view_credentials.password_hash_type_name FROM view_credentials
     WHERE view_credentials.password_hash IS NOT NULL;
grant select on view_password_hashes to yaptest_user;

create view view_issues as (SELECT test_areas.id AS test_area_id, test_areas.name AS test_area_name, issues.id AS issue_id, issues.shortname AS issue_shortname, hosts.id AS host_id, hosts.ip_address, ports.id AS port_id, ports.port, ports.transport_protocol_id, transport_protocols.name AS transport_protocol_name
   FROM issues_to_ports
      JOIN issues ON issues.id = issues_to_ports.issue_id
         JOIN ports ON ports.id = issues_to_ports.port_id
	    JOIN hosts ON hosts.id = ports.host_id
	       JOIN test_areas ON test_areas.id = hosts.test_area_id
	          JOIN transport_protocols ON ports.transport_protocol_id = transport_protocols.id
		  UNION
		   SELECT test_areas.id AS test_area_id, test_areas.name AS test_area_name, issues.id AS issue_id, issues.shortname AS issue_shortname, hosts.id AS host_id, hosts.ip_address, NULL::"unknown" AS port_id, NULL::"unknown" AS port, NULL::"unknown" AS transport_protocol_id, NULL::"unknown" AS transport_protocol_name
		      FROM issues_to_hosts
		         JOIN issues ON issues.id = issues_to_hosts.issue_id
			    JOIN hosts ON hosts.id = issues_to_hosts.host_id
			       JOIN test_areas ON test_areas.id = hosts.test_area_id)
			       UNION
			        SELECT test_areas.id AS test_area_id, test_areas.name AS test_area_name, issues.id AS issue_id, issues.shortname AS issue_shortname, NULL::"unknown" AS host_id, NULL::"unknown" AS ip_address, NULL::"unknown" AS port_id, NULL::"unknown" AS port, NULL::"unknown" AS transport_protocol_id, NULL::"unknown" AS transport_protocol_name
				   FROM issues_to_testareas
				      JOIN issues ON issues.id = issues_to_testareas.issue_id
				         JOIN test_areas ON test_areas.id = issues_to_testareas.testarea_id;

grant select on view_issues to yaptest_user;

create view view_groups as SELECT test_areas.name AS group_test_area_name, test_areas.id AS group_test_area_id, h1.ip_address AS group_ip, h1.id AS group_host_id, c1.username AS group_name, h2.ip_address AS member_ip, h2.id AS member_host_id, c2."domain" AS member_domain, c2.username AS member_name, c2."group" AS member_type
   FROM credentials c1
      LEFT JOIN group_memberships ON c1.id = group_memberships.group_id
         LEFT JOIN credentials c2 ON group_memberships.member_id = c2.id
	    JOIN hosts h1 ON c1.host_id = h1.id
	       LEFT JOIN hosts h2 ON c2.host_id = h2.id
	          JOIN test_areas ON h1.test_area_id = test_areas.id
		    WHERE c1."group" IS TRUE;

grant select on view_groups to yaptest_user;

create or replace view view_mac_addresses as SELECT test_areas.name AS test_area_name, test_areas.id AS test_area_id, hosts.ip_address, hosts.id AS host_id, mac_addresses.mac_address, value as mac_vendor from hosts_to_mac_addresses JOIN mac_addresses ON hosts_to_mac_addresses.mac_address_id = mac_addresses.id JOIN hosts ON hosts_to_mac_addresses.host_id = hosts.id JOIN test_areas ON test_areas.id = hosts.test_area_id left join view_host_info on hosts.id = view_host_info.host_id and view_host_info.key = 'mac_vendor';
grant select on view_mac_addresses to yaptest_user;




create view view_insecure_protos as SELECT distinct
        CASE
            WHEN view_port_info.port_info_key = 'nmap_service_name'::text THEN view_port_info.value
            ELSE NULL::text
        END AS nmap_service_name, view_port_info.test_area_id, view_port_info.test_area_name, view_port_info.host_id, view_port_info.ip_address, view_port_info.port_id, view_port_info.port, view_port_info.transport_protocol
   FROM view_port_info
  WHERE view_port_info.port_info_key = 'nmap_service_name'::text AND (view_port_info.value = 'microsoft-rdp'::text OR view_port_info.value = 'http'::text OR view_port_info.value = 'ms-sql-s'::text OR view_port_info.value = 'ldap'::text) OR view_port_info.port = 21 OR view_port_info.port = 23 OR view_port_info.port = 512 OR view_port_info.port = 513 OR view_port_info.port = 514 OR view_port_info.port = 161 OR view_port_info.port = 110 OR view_port_info.port = 143 OR view_port_info.port = 69 OR view_port_info.port = 177
  

except (
  SELECT view_port_info_ssl.value AS nmap_service_name, view_port_info_ssl.test_area_id, view_port_info_ssl.test_area_name, view_port_info_ssl.host_id, view_port_info_ssl.ip_address, view_port_info_ssl.port_id, view_port_info_ssl.port, view_port_info_ssl.transport_protocol   
  FROM view_port_info_ssl
  WHERE nmap_service_tunnel = 'ssl' and view_port_info_ssl.port_info_key = 'nmap_service_name'::text AND (view_port_info_ssl.value = 'http'::text or view_port_info_ssl.value = 'ldap'::text )
)

ORDER BY nmap_service_name, port, ip_address
;


ALTER TABLE public.view_insecure_protos OWNER TO postgres;
REVOKE ALL ON TABLE view_insecure_protos FROM PUBLIC;
REVOKE ALL ON TABLE view_insecure_protos FROM postgres;
GRANT ALL ON TABLE view_insecure_protos TO postgres;
GRANT SELECT ON TABLE view_insecure_protos TO yaptest_user;
grant select, update on test_areas_id_seq to yaptest_user;
grant select, update on hosts_id_seq to yaptest_user;
-- Name: app_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.app_protocols OWNER TO yaptest_user;
-- Name: hostname_types; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.hostname_types OWNER TO yaptest_user;
-- Name: hostnames; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.hostnames OWNER TO yaptest_user;
-- Name: hosts_to_mac_addresses; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.hosts_to_mac_addresses OWNER TO yaptest_user;
-- Name: mac_addresses; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.mac_addresses OWNER TO yaptest_user;
-- Name: ports; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.ports OWNER TO yaptest_user;
-- Name: ports_to_app_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.ports_to_app_protocols OWNER TO yaptest_user;
-- Name: transport_protocols; Type: TABLE; Schema: public; Owner: yaptest_user; Tablespace: 
ALTER TABLE public.transport_protocols OWNER TO yaptest_user;
-- Name: hostnames_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: hostnames_name_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: hosts_to_mac_addresses_ip_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: hosts_to_mac_addresses_mac_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: ports_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: ports_to_app_protocols_app_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: ports_to_app_protocols_port_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: ports_transport_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yaptest_user
-- Name: app_protocols; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE app_protocols FROM yaptest_user;
GRANT ALL ON TABLE app_protocols TO yaptest_user;
GRANT INSERT,SELECT ON TABLE command_log TO yaptest_user;
-- Name: command_log_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE command_log_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE command_log_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE command_log_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE command_log_id_seq TO yaptest_user;
GRANT INSERT,SELECT ON TABLE command_status TO yaptest_user;
-- Name: command_status_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE command_status_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE command_status_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE command_status_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE command_status_id_seq TO yaptest_user;
GRANT INSERT,SELECT ON TABLE commands TO yaptest_user;
-- Name: commands_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE commands_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE commands_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE commands_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE commands_id_seq TO yaptest_user;
GRANT INSERT,SELECT ON TABLE credential_types TO yaptest_user;
-- Name: credential_types_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE credential_types_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE credential_types_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE credential_types_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE credential_types_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE ON TABLE credentials TO yaptest_user;
-- Name: credentials_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE credentials_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE credentials_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE credentials_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE credentials_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE group_memberships TO yaptest_user;
-- Name: group_memberships_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE group_memberships_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE group_memberships_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE group_memberships_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE group_memberships_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE host_info TO yaptest_user;
-- Name: host_info_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE host_info_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE host_info_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE host_info_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE host_info_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE host_keys TO yaptest_user;
-- Name: host_keys_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE host_keys_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE host_keys_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE host_keys_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE host_keys_id_seq TO yaptest_user;
GRANT INSERT,SELECT,DELETE ON TABLE host_progress TO yaptest_user;
-- Name: host_progress_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE host_progress_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE host_progress_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE host_progress_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE host_progress_id_seq TO yaptest_user;
-- Name: hostname_types; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE hostname_types FROM yaptest_user;
GRANT ALL ON TABLE hostname_types TO yaptest_user;
-- Name: hostnames; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE hostnames FROM yaptest_user;
GRANT ALL ON TABLE hostnames TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE hosts TO yaptest_user;
-- Name: hosts_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE hosts_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE hosts_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE hosts_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE hosts_id_seq TO yaptest_user;
-- Name: hosts_to_mac_addresses; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE hosts_to_mac_addresses FROM yaptest_user;
GRANT ALL ON TABLE hosts_to_mac_addresses TO yaptest_user;
GRANT INSERT,SELECT ON TABLE icmp TO yaptest_user;
-- Name: icmp_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE icmp_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE icmp_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE icmp_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE icmp_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE ON TABLE issues TO yaptest_user;
-- Name: issues_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE issues_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE issues_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE issues_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE issues_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE issues_to_hosts TO yaptest_user;
-- Name: issues_to_hosts_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE issues_to_hosts_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE issues_to_hosts_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE issues_to_hosts_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE issues_to_hosts_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE issues_to_ports TO yaptest_user;
-- Name: issues_to_ports_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE issues_to_ports_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE issues_to_ports_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE issues_to_ports_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE issues_to_ports_id_seq TO yaptest_user;
-- Name: mac_addresses; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE mac_addresses FROM yaptest_user;
GRANT ALL ON TABLE mac_addresses TO yaptest_user;
GRANT INSERT,SELECT ON TABLE password_hash_types TO yaptest_user;
-- Name: password_hash_types_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE password_hash_types_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE password_hash_types_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE password_hash_types_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE password_hash_types_id_seq TO yaptest_user;
GRANT INSERT,SELECT ON TABLE password_types TO yaptest_user;
-- Name: password_types_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE password_types_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE password_types_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE password_types_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE password_types_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE ON TABLE port_info TO yaptest_user;
-- Name: port_info_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE port_info_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE port_info_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE port_info_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE port_info_id_seq TO yaptest_user;
GRANT INSERT,SELECT ON TABLE port_keys TO yaptest_user;
-- Name: port_keys_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE port_keys_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE port_keys_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE port_keys_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE port_keys_id_seq TO yaptest_user;
GRANT INSERT,SELECT,DELETE ON TABLE port_progress TO yaptest_user;
-- Name: port_progress_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE port_progress_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE port_progress_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE port_progress_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE port_progress_id_seq TO yaptest_user;
-- Name: ports; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE ports FROM yaptest_user;
GRANT ALL ON TABLE ports TO yaptest_user;
-- Name: ports_to_app_protocols; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE ports_to_app_protocols FROM yaptest_user;
GRANT ALL ON TABLE ports_to_app_protocols TO yaptest_user;
GRANT INSERT,SELECT ON TABLE progress_states TO yaptest_user;
-- Name: progress_states_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE progress_states_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE progress_states_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE progress_states_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE progress_states_id_seq TO yaptest_user;
GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE test_areas TO yaptest_user;
-- Name: test_areas_id_seq; Type: ACL; Schema: public; Owner: postgres
REVOKE ALL ON TABLE test_areas_id_seq FROM PUBLIC;
REVOKE ALL ON TABLE test_areas_id_seq FROM postgres;
GRANT SELECT,UPDATE ON TABLE test_areas_id_seq TO postgres;
GRANT SELECT,UPDATE ON TABLE test_areas_id_seq TO yaptest_user;
-- Name: transport_protocols; Type: ACL; Schema: public; Owner: yaptest_user
REVOKE ALL ON TABLE transport_protocols FROM yaptest_user;


GRANT ALL ON TABLE transport_protocols TO yaptest_user;
GRANT SELECT ON TABLE view_command_log TO yaptest_user;
GRANT SELECT ON TABLE view_credentials TO yaptest_user;
GRANT SELECT ON TABLE view_groups TO yaptest_user;
GRANT SELECT ON TABLE view_host_info TO yaptest_user;
GRANT SELECT ON TABLE view_host_issues TO yaptest_user;
GRANT SELECT ON TABLE view_host_progress TO yaptest_user;
GRANT SELECT ON TABLE view_hosts TO yaptest_user;
GRANT SELECT ON TABLE view_port_info TO yaptest_user;
GRANT SELECT ON TABLE view_http_banners TO yaptest_user;
GRANT SELECT ON TABLE view_icmp TO yaptest_user;
GRANT SELECT ON TABLE view_insecure_protos TO yaptest_user;
GRANT SELECT ON TABLE view_issues TO yaptest_user;
GRANT SELECT ON TABLE view_mac_addresses TO yaptest_user;
GRANT SELECT ON TABLE view_os TO yaptest_user;
GRANT SELECT ON TABLE view_password_hashes TO yaptest_user;
GRANT SELECT ON TABLE view_port_info_ssl TO yaptest_user;
GRANT SELECT ON TABLE view_port_issues TO yaptest_user;
GRANT SELECT ON TABLE view_port_progress TO yaptest_user;
GRANT SELECT ON TABLE view_ports TO yaptest_user;
GRANT SELECT ON TABLE view_port_summary TO yaptest_user;
GRANT SELECT ON TABLE view_port_summary_by_test_area TO yaptest_user;
GRANT SELECT ON TABLE view_ssh_banners TO yaptest_user;
GRANT SELECT ON TABLE icmp_names TO yaptest_user;

COPY icmp_names (id, icmp_type, icmp_code, name) FROM stdin with DELIMITER '	';
1	0	0	Echo Reply
2	8	0	Echo Request
3	13	0	Timestamp Request
4	14	0	Timestamp Reply
5	16	0	Information Reply
6	15	0	Information Request
7	17	0	Address Mask Request
8	18	0	Address Mask Reply
\.

COPY transport_protocols (id, name) FROM stdin with DELIMITER '	';
1	TCP
2	UDP
\.

create table boxes      (id serial primary key not null, test_area_id int references test_areas(id) not null, label text);
create table interfaces (id serial primary key not null, box_id       int references boxes(id)      not null, ip_address  inet not null, icmp_ttl int, netmask inet);
create table topology   (id serial primary key not null, interface_id int references interfaces(id) not null, prev_hop_interface_id int references interfaces(id) not null, comment text);
grant select, insert on boxes to yaptest_user;
grant select, update, insert on interfaces to yaptest_user;
grant select, insert on topology to yaptest_user;


grant select, update on boxes_id_seq to yaptest_user;
grant select, update on interfaces_id_seq to yaptest_user;
grant select, update on topology_id_seq to yaptest_user;

alter table interfaces add column hop int;
create view view_topology as SELECT i1.hop AS hop_number, i2.hop AS prev_hop_number, test_areas.name AS test_area_name, boxes.test_area_id, i1.ip_address, i2.ip_address AS prev_hop_ip, i1.id AS interface_id, i2.id AS prev_hop_interface_id
   FROM topology
      JOIN interfaces i1 ON topology.interface_id = i1.id
         JOIN interfaces i2 ON topology.prev_hop_interface_id = i2.id
	    JOIN boxes ON i1.box_id = boxes.id
	       JOIN test_areas ON boxes.test_area_id = test_areas.id;

grant select on view_topology to yaptest_user;

create view view_interfaces as SELECT test_areas.name, interfaces.box_id, interfaces.ip_address, interfaces.icmp_ttl, boxes.label, interfaces.netmask FROM interfaces JOIN boxes ON interfaces.box_id = boxes.id JOIN test_areas ON test_areas.id = boxes.test_area_id;
grant select on view_interfaces to yaptest_user;

create table host_info_progress (id serial primary key not null, host_info_id int references host_info(id) not null, command_id int references commands(id) not null, state_id int references progress_states(id) not null);
grant select, insert, update, delete on host_info_progress to yaptest_user;

create table port_info_progress (id serial primary key not null, port_info_id int references port_info(id) not null, command_id int references commands(id) not null, state_id int references progress_states(id) not null);
grant select, insert, update, delete on port_info_progress to yaptest_user;

create table credentials_progress (id serial primary key not null, credential_id int references credentials(id) not null, command_id int references commands(id) not null, state_id int references progress_states(id) not null);
grant select, insert, update, delete on credentials_progress to yaptest_user;

create table hostname_progress (id serial primary key not null, hostname_id int references hostnames(id) not null, command_id int references commands(id) not null, state_id int references progress_states(id) not null);
grant select, insert, update, delete on hostname_progress to yaptest_user;

create view view_host_info_progress as select host_info.id as host_info_id, test_areas.name AS test_area_name, hosts.ip_address, commands.name AS command, progress_states.name AS state FROM host_info_progress JOIN host_info on host_info_progress.host_info_id = host_info.id join hosts ON host_info.host_id = hosts.id JOIN commands ON host_info_progress.command_id = commands.id JOIN progress_states ON progress_states.id = host_info_progress.state_id JOIN test_areas ON hosts.test_area_id = test_areas.id ORDER BY test_areas.name, commands.name, hosts.ip_address;

grant select on view_host_info_progress to yaptest_user;

create view view_port_info_progress as select port_info.id as port_info_id, test_areas.name AS test_area_name, hosts.ip_address, commands.name AS command, progress_states.name AS state FROM port_info_progress JOIN port_info on port_info_progress.port_info_id = port_info.id join ports on ports.id = port_info.port_id join hosts ON ports.host_id = hosts.id JOIN commands ON port_info_progress.command_id = commands.id JOIN progress_states ON progress_states.id = port_info_progress.state_id JOIN test_areas ON hosts.test_area_id = test_areas.id ORDER BY test_areas.name, commands.name, hosts.ip_address;

grant select on view_port_info_progress to yaptest_user;

grant select, update on port_info_progress_id_seq to yaptest_user;

CREATE INDEX credspeedup ON credentials USING btree (host_id, port_id, "domain", username, password_hash_type_id, credential_type_id);
CREATE INDEX credspeedup2 ON credentials USING btree (hash_half2, password_hash_type_id);
CREATE INDEX credspeedup3 ON credentials USING btree (hash_half1, password_hash_type_id);
CREATE INDEX credspeedup4 ON credentials USING btree ("password", hash_half1, hash_half2, password_hash_type_id);
CREATE INDEX credspeedup5 ON credentials USING btree (password_hash, password_hash_type_id);
CREATE INDEX icmp_names_uidx ON icmp USING btree (icmp_type, icmp_code);
CREATE INDEX icmp_uidx ON icmp USING btree (icmp_type, icmp_code, host_id);

CREATE VIEW view_windows_host_info as SELECT DISTINCT hosts.id AS host_id, test_areas.id AS test_area_id, test_areas.name AS test_area_name, hosts.ip_address, hostnames.name AS hostname, v1.value AS os, v2.value AS dom_name,
        CASE
            WHEN v3.value IS NULL THEN 'N'::text
            ELSE 'Y'::text
        END AS dc, v4.value AS member_of, v5.value AS smb_server_version, v6.value AS device_info, v7.value AS domain_sid, v8.value AS pwd_complexity_flags, v9.value AS lockout_threshold, v10.value AS lockout_duration, v11.value AS reset_lockout_ctr, v12.value AS windows_long_dom
   FROM host_info
   JOIN hosts ON host_info.host_id = hosts.id
   JOIN hostnames ON host_info.host_id = hostnames.host_id
   JOIN hostname_types ON hostnames.name_type = hostname_types.id
   JOIN host_keys ON host_info.host_key_id = host_keys.id
   JOIN test_areas ON hosts.test_area_id = test_areas.id
   LEFT JOIN view_host_info v1 ON hosts.id = v1.host_id AND v1."key"::text = 'os'::text
   LEFT JOIN view_host_info v2 ON hosts.id = v2.host_id AND v2."key"::text = 'windows_domwkg'::text
   LEFT JOIN view_host_info v3 ON hosts.id = v3.host_id AND v3."key"::text = 'windows_dc'::text
   LEFT JOIN view_host_info v4 ON hosts.id = v4.host_id AND v4."key"::text = 'windows_member_of'::text
   LEFT JOIN view_host_info v5 ON hosts.id = v5.host_id AND v5."key"::text = 'smb_server'::text
   LEFT JOIN view_host_info v6 ON hosts.id = v6.host_id AND v6."key"::text = 'device_info'::text
   LEFT JOIN view_host_info v7 ON hosts.id = v7.host_id AND v7."key"::text = 'windows_domain_sid'::text
   LEFT JOIN view_host_info v8 ON hosts.id = v8.host_id AND v8."key"::text = 'windows_password_complexity'::text
   LEFT JOIN view_host_info v9 ON hosts.id = v9.host_id AND v9."key"::text = 'windows_acct_lockout_threshold'::text
   LEFT JOIN view_host_info v10 ON hosts.id = v10.host_id AND v10."key"::text = 'windows_acct_lockout_duration'::text
   LEFT JOIN view_host_info v11 ON hosts.id = v11.host_id AND v11."key"::text = 'windows_reset_acct_lockout_ctr'::text
   LEFT JOIN view_host_info v12 ON hosts.id = v12.host_id AND v12."key"::text = 'windows_long_dom'::text
  WHERE hostname_types.name_type::text = 'windows_hostname'::text
  ORDER BY hosts.id, test_areas.id, test_areas.name, hosts.ip_address, hostnames.name, v1.value, v2.value,
CASE
    WHEN v3.value IS NULL THEN 'N'::text
    ELSE 'Y'::text
END, v4.value, v5.value, v6.value, v7.value, v8.value, v9.value, v10.value, v11.value, v12.value;

GRANT SELECT ON view_windows_host_info TO yaptest_user;


create view view_nmap_info as SELECT p1.value, p1.port_info_id, p1.port_info_key, vp.port_id, vp.host_id, vp.ip_address, vp.test_area_id, vp.test_area_name, vp.port, vp.transport_protocol, p1.value AS nmap_service, p2.value AS nmap_version
   FROM view_ports vp
      LEFT JOIN view_port_info p1 ON vp.port_id = p1.port_id AND p1.port_info_key = 'nmap_service_name'::text
         LEFT JOIN view_port_info p2 ON vp.port_id = p2.port_id AND p2.port_info_key = 'nmap_service_version'::text;

grant select on view_nmap_info to yaptest_user;

drop view view_windows_host_info;
create or replace view view_hosts_ytfe as
select view_hosts.host_id, view_hosts.test_area_id, view_hosts.test_area_name, view_hosts.ip_address, hostname, name_type, hi1.value as finished, hi2.value as owned
from view_hosts
left join view_host_info as hi1 on view_hosts.host_id = hi1.host_id and hi1.key = 'yaptestfe_finished'
left join view_host_info as hi2 on view_hosts.host_id = hi2.host_id and hi2.key = 'yaptestfe_owned';
grant select on view_hosts_ytfe to yaptest_user;

create view view_windows_host_info as
 SELECT DISTINCT hosts.id AS host_id, test_areas.id AS test_area_id, test_areas.name AS test_area_name, hosts.ip_address, hostnames.name AS hostname, v1.value AS os, v2.value AS dom_name,
        CASE
            WHEN v3.value IS NULL THEN 'N'::text
            ELSE 'Y'::text
        END AS dc, v4.value AS member_of, v5.value AS smb_server_version, v6.value AS device_info, v7.value AS domain_sid, v8.value AS pwd_complexity_flags, v9.value AS lockout_threshold, v10.value AS lockout_duration, v11.value AS reset_lockout_ctr, v12.value AS windows_long_dom
   FROM host_info
   JOIN hosts ON host_info.host_id = hosts.id
   JOIN hostnames ON host_info.host_id = hostnames.host_id
   JOIN hostname_types ON hostnames.name_type = hostname_types.id
   JOIN host_keys ON host_info.host_key_id = host_keys.id
   JOIN test_areas ON hosts.test_area_id = test_areas.id
   LEFT JOIN view_host_info v1 ON hosts.id = v1.host_id AND v1."key"::text = 'os'::text
   LEFT JOIN view_host_info v2 ON hosts.id = v2.host_id AND v2."key"::text = 'windows_domwkg'::text
   LEFT JOIN view_host_info v3 ON hosts.id = v3.host_id AND v3."key"::text = 'windows_dc'::text
   LEFT JOIN view_host_info v4 ON hosts.id = v4.host_id AND v4."key"::text = 'windows_member_of'::text
   LEFT JOIN view_host_info v5 ON hosts.id = v5.host_id AND v5."key"::text = 'smb_server'::text
   LEFT JOIN view_host_info v6 ON hosts.id = v6.host_id AND v6."key"::text = 'device_info'::text
   LEFT JOIN view_host_info v7 ON hosts.id = v7.host_id AND v7."key"::text = 'windows_domain_sid'::text
   LEFT JOIN view_host_info v8 ON hosts.id = v8.host_id AND v8."key"::text = 'windows_password_complexity'::text
   LEFT JOIN view_host_info v9 ON hosts.id = v9.host_id AND v9."key"::text = 'windows_acct_lockout_threshold'::text
   LEFT JOIN view_host_info v10 ON hosts.id = v10.host_id AND v10."key"::text = 'windows_acct_lockout_duration'::text
   LEFT JOIN view_host_info v11 ON hosts.id = v11.host_id AND v11."key"::text = 'windows_reset_acct_lockout_ctr'::text
   LEFT JOIN view_host_info v12 ON hosts.id = v12.host_id AND v12."key"::text = 'windows_long_dom'::text
  WHERE hostname_types.name_type::text = 'windows_hostname'::text
  ORDER BY hosts.id, test_areas.id, test_areas.name, hosts.ip_address, hostnames.name, v1.value, v2.value,
CASE
    WHEN v3.value IS NULL THEN 'N'::text
    ELSE 'Y'::text
END, v4.value, v5.value, v6.value, v7.value, v8.value, v9.value, v10.value, v11.value, v12.value;
grant select on view_windows_host_info to yaptest_user;
