--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: app_protocols; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE app_protocols (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    amap_name character varying(100),
    nmap_name character varying(100)
);



--
-- Name: app_protocols_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE app_protocols_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: app_protocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE app_protocols_id_seq OWNED BY app_protocols.id;


--
-- Name: boxes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE boxes (
    id integer NOT NULL,
    test_area_id integer NOT NULL,
    label text
);



--
-- Name: boxes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE boxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: boxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE boxes_id_seq OWNED BY boxes.id;


--
-- Name: command_log; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE command_log (
    id integer NOT NULL,
    "time" timestamp without time zone DEFAULT now() NOT NULL,
    command text NOT NULL,
    command_status_id integer NOT NULL
);



--
-- Name: command_log_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE command_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: command_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE command_log_id_seq OWNED BY command_log.id;


--
-- Name: command_status; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE command_status (
    id integer NOT NULL,
    name character varying(15) NOT NULL
);



--
-- Name: command_status_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE command_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: command_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE command_status_id_seq OWNED BY command_status.id;


--
-- Name: commands; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE commands (
    id integer NOT NULL,
    name text NOT NULL,
    hash text
);



--
-- Name: commands_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE commands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE commands_id_seq OWNED BY commands.id;


--
-- Name: credential_types; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE credential_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text
);



--
-- Name: credential_types_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE credential_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: credential_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE credential_types_id_seq OWNED BY credential_types.id;


--
-- Name: credentials; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE credentials (
    id integer NOT NULL,
    uid integer,
    host_id integer NOT NULL,
    port_id integer,
    credential_type_id integer NOT NULL,
    domain character varying(30),
    username character varying(100),
    password character varying(20),
    password_hash character varying(100),
    password_hash_type_id integer,
    password_half1 character varying(7),
    password_half2 character varying(7),
    hash_half1 character varying(16),
    hash_half2 character varying(16),
    "group" boolean DEFAULT false NOT NULL
);



--
-- Name: credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE credentials_id_seq OWNED BY credentials.id;


--
-- Name: credentials_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE credentials_progress (
    id integer NOT NULL,
    credential_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: credentials_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE credentials_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: credentials_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE credentials_progress_id_seq OWNED BY credentials_progress.id;


--
-- Name: custom_entities; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE custom_entities (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: custom_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE custom_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: custom_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE custom_entities_id_seq OWNED BY custom_entities.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE group_memberships (
    id integer NOT NULL,
    group_id integer NOT NULL,
    member_id integer NOT NULL
);



--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE group_memberships_id_seq OWNED BY group_memberships.id;


--
-- Name: host_info; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE host_info (
    id integer NOT NULL,
    host_id integer NOT NULL,
    host_key_id integer NOT NULL,
    value text
);



--
-- Name: host_info_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE host_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: host_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE host_info_id_seq OWNED BY host_info.id;


--
-- Name: host_info_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE host_info_progress (
    id integer NOT NULL,
    host_info_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: host_info_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE host_info_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: host_info_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE host_info_progress_id_seq OWNED BY host_info_progress.id;


--
-- Name: host_keys; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE host_keys (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text
);



--
-- Name: host_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE host_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: host_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE host_keys_id_seq OWNED BY host_keys.id;


--
-- Name: host_progress; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE host_progress (
    id integer NOT NULL,
    host_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: host_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE host_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: host_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE host_progress_id_seq OWNED BY host_progress.id;


--
-- Name: hostname_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE hostname_progress (
    id integer NOT NULL,
    hostname_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: hostname_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hostname_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: hostname_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE hostname_progress_id_seq OWNED BY hostname_progress.id;


--
-- Name: hostname_types; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE hostname_types (
    id integer NOT NULL,
    name_type character varying(100) NOT NULL
);



--
-- Name: hostname_types_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE hostname_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: hostname_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE hostname_types_id_seq OWNED BY hostname_types.id;


--
-- Name: hostnames; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE hostnames (
    id integer NOT NULL,
    name_type integer NOT NULL,
    name text NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: hostnames_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE hostnames_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: hostnames_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE hostnames_id_seq OWNED BY hostnames.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    ip_address inet NOT NULL,
    test_area_id integer NOT NULL
);



--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: hosts_to_mac_addresses; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE hosts_to_mac_addresses (
    id integer NOT NULL,
    mac_address_id integer NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: hosts_to_mac_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE hosts_to_mac_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: hosts_to_mac_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE hosts_to_mac_addresses_id_seq OWNED BY hosts_to_mac_addresses.id;


--
-- Name: icmp; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE icmp (
    id integer NOT NULL,
    icmp_type smallint NOT NULL,
    icmp_code smallint NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: icmp_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE icmp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: icmp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE icmp_id_seq OWNED BY icmp.id;


--
-- Name: icmp_names; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE icmp_names (
    id integer NOT NULL,
    icmp_type smallint NOT NULL,
    icmp_code smallint NOT NULL,
    name character varying(255)
);



--
-- Name: icmp_names_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE icmp_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: icmp_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE icmp_names_id_seq OWNED BY icmp_names.id;


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE interfaces (
    id integer NOT NULL,
    box_id integer NOT NULL,
    ip_address inet NOT NULL,
    icmp_ttl integer,
    netmask inet,
    hop integer
);



--
-- Name: interfaces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE interfaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: interfaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE interfaces_id_seq OWNED BY interfaces.id;


--
-- Name: issue_ratings; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issue_ratings (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: issue_ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issue_ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issue_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issue_ratings_id_seq OWNED BY issue_ratings.id;


--
-- Name: issue_sources; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issue_sources (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: issue_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issue_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issue_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issue_sources_id_seq OWNED BY issue_sources.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issues (
    id integer NOT NULL,
    shortname character varying(60),
    title text,
    description text,
    rating integer,
    source integer
);



--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;


--
-- Name: issues_to_custom_entities; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issues_to_custom_entities (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    entity_id integer NOT NULL
);



--
-- Name: issues_to_custom_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issues_to_custom_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issues_to_custom_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issues_to_custom_entities_id_seq OWNED BY issues_to_custom_entities.id;


--
-- Name: issues_to_hosts; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issues_to_hosts (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: issues_to_hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issues_to_hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issues_to_hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issues_to_hosts_id_seq OWNED BY issues_to_hosts.id;


--
-- Name: issues_to_ports; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issues_to_ports (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    port_id integer NOT NULL
);



--
-- Name: issues_to_ports_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issues_to_ports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issues_to_ports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issues_to_ports_id_seq OWNED BY issues_to_ports.id;


--
-- Name: issues_to_testareas; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE issues_to_testareas (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    testarea_id integer NOT NULL
);



--
-- Name: issues_to_testareas_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE issues_to_testareas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: issues_to_testareas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE issues_to_testareas_id_seq OWNED BY issues_to_testareas.id;


--
-- Name: mac_addresses; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE mac_addresses (
    id integer NOT NULL,
    mac_address macaddr NOT NULL
);



--
-- Name: mac_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE mac_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: mac_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE mac_addresses_id_seq OWNED BY mac_addresses.id;


--
-- Name: password_hash_types; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE password_hash_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text
);



--
-- Name: password_hash_types_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE password_hash_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: password_hash_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE password_hash_types_id_seq OWNED BY password_hash_types.id;


--
-- Name: password_types; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE password_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text
);



--
-- Name: password_types_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE password_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: password_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE password_types_id_seq OWNED BY password_types.id;


--
-- Name: port_info; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE port_info (
    id integer NOT NULL,
    port_id integer,
    key_id integer NOT NULL,
    value text
);



--
-- Name: port_info_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE port_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: port_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE port_info_id_seq OWNED BY port_info.id;


--
-- Name: port_info_progress; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE port_info_progress (
    id integer NOT NULL,
    port_info_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: port_info_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE port_info_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: port_info_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE port_info_progress_id_seq OWNED BY port_info_progress.id;


--
-- Name: port_keys; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE port_keys (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: port_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE port_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: port_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE port_keys_id_seq OWNED BY port_keys.id;


--
-- Name: port_progress; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE port_progress (
    id integer NOT NULL,
    port_id integer NOT NULL,
    command_id integer NOT NULL,
    state_id integer NOT NULL
);



--
-- Name: port_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE port_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: port_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE port_progress_id_seq OWNED BY port_progress.id;


--
-- Name: ports; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE ports (
    id integer NOT NULL,
    transport_protocol_id integer NOT NULL,
    port integer NOT NULL,
    host_id integer NOT NULL
);



--
-- Name: ports_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE ports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: ports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE ports_id_seq OWNED BY ports.id;


--
-- Name: ports_to_app_protocols; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE ports_to_app_protocols (
    id integer NOT NULL,
    port_id integer NOT NULL,
    app_protocol_id integer NOT NULL,
    layer_no integer NOT NULL
);



--
-- Name: ports_to_app_protocols_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE ports_to_app_protocols_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: ports_to_app_protocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE ports_to_app_protocols_id_seq OWNED BY ports_to_app_protocols.id;


--
-- Name: progress_states; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE progress_states (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: progress_states_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE progress_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: progress_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE progress_states_id_seq OWNED BY progress_states.id;


--
-- Name: test_areas; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE test_areas (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);



--
-- Name: test_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE test_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: test_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE test_areas_id_seq OWNED BY test_areas.id;


--
-- Name: topology; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE topology (
    id integer NOT NULL,
    interface_id integer NOT NULL,
    prev_hop_interface_id integer NOT NULL,
    comment text
);



--
-- Name: topology_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE topology_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: topology_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE topology_id_seq OWNED BY topology.id;


--
-- Name: transport_protocols; Type: TABLE; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE TABLE transport_protocols (
    id integer NOT NULL,
    name character varying(10) NOT NULL
);



--
-- Name: transport_protocols_id_seq; Type: SEQUENCE; Schema: public; Owner: yaptest
--

CREATE SEQUENCE transport_protocols_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: transport_protocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yaptest
--

ALTER SEQUENCE transport_protocols_id_seq OWNED BY transport_protocols.id;


--
-- Name: view_command_log; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_command_log AS
 SELECT command_log."time",
    command_log.command,
    command_status.name AS status
   FROM (command_log
     JOIN command_status ON ((command_log.command_status_id = command_status.id)));



--
-- Name: view_credentials; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_credentials AS
 SELECT test_areas.name AS test_area_name,
    test_areas.id AS test_area_id,
    credential_types.name AS credential_type_name,
    hosts.ip_address,
    hosts.id AS host_id,
    ports.port,
    transport_protocols.name AS transport_protocol_name,
    ports.id AS port_id,
    transport_protocols.id AS transport_protocol_id,
    credentials.domain,
    credentials.uid,
    credentials.username,
    credentials.password,
    credentials.password_hash,
    password_hash_types.name AS password_hash_type_name
   FROM ((((((credentials
     JOIN hosts ON ((credentials.host_id = hosts.id)))
     JOIN credential_types ON ((credentials.credential_type_id = credential_types.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
     LEFT JOIN password_hash_types ON ((credentials.password_hash_type_id = password_hash_types.id)))
     LEFT JOIN ports ON ((credentials.port_id = ports.id)))
     LEFT JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
  WHERE (credentials."group" IS FALSE)
  ORDER BY hosts.ip_address, ports.port, transport_protocols.name, credential_types.name, credentials.domain, password_hash_types.name, credentials.username, credentials.password;



--
-- Name: view_groups; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_groups AS
 SELECT test_areas.name AS group_test_area_name,
    test_areas.id AS group_test_area_id,
    h1.ip_address AS group_ip,
    h1.id AS group_host_id,
    c1.username AS group_name,
    h2.ip_address AS member_ip,
    h2.id AS member_host_id,
    c2.domain AS member_domain,
    c2.username AS member_name,
    c2."group" AS member_type
   FROM (((((credentials c1
     LEFT JOIN group_memberships ON ((c1.id = group_memberships.group_id)))
     LEFT JOIN credentials c2 ON ((group_memberships.member_id = c2.id)))
     JOIN hosts h1 ON ((c1.host_id = h1.id)))
     LEFT JOIN hosts h2 ON ((c2.host_id = h2.id)))
     JOIN test_areas ON ((h1.test_area_id = test_areas.id)))
  WHERE (c1."group" IS TRUE);



--
-- Name: view_host_info; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_host_info AS
 SELECT test_areas.name AS test_area_name,
    test_areas.id AS test_area_id,
    hosts.id AS host_id,
    hosts.ip_address,
    host_keys.name AS key,
    host_info.value
   FROM (((hosts
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
     JOIN host_info ON ((host_info.host_id = hosts.id)))
     JOIN host_keys ON ((host_info.host_key_id = host_keys.id)))
  ORDER BY test_areas.name, hosts.ip_address;



--
-- Name: view_host_info_progress; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_host_info_progress AS
 SELECT host_info.id AS host_info_id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    commands.name AS command,
    progress_states.name AS state
   FROM (((((host_info_progress
     JOIN host_info ON ((host_info_progress.host_info_id = host_info.id)))
     JOIN hosts ON ((host_info.host_id = hosts.id)))
     JOIN commands ON ((host_info_progress.command_id = commands.id)))
     JOIN progress_states ON ((progress_states.id = host_info_progress.state_id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, commands.name, hosts.ip_address;



--
-- Name: view_host_issues; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_host_issues AS
 SELECT issues_to_hosts.id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    issues.shortname AS issue
   FROM (((issues_to_hosts
     JOIN hosts ON ((hosts.id = issues_to_hosts.host_id)))
     JOIN issues ON ((issues_to_hosts.issue_id = issues.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, hosts.ip_address, issues.shortname;



--
-- Name: view_host_progress; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_host_progress AS
 SELECT hosts.id AS host_id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    commands.name AS command,
    progress_states.name AS state
   FROM ((((host_progress
     JOIN hosts ON ((host_progress.host_id = hosts.id)))
     JOIN commands ON ((host_progress.command_id = commands.id)))
     JOIN progress_states ON ((progress_states.id = host_progress.state_id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, commands.name, hosts.ip_address;



--
-- Name: view_hosts; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_hosts AS
 SELECT hosts.id AS host_id,
    test_areas.id AS test_area_id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    hostnames.name AS hostname,
    hostname_types.name_type
   FROM (((hosts
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
     LEFT JOIN hostnames ON ((hostnames.host_id = hosts.id)))
     LEFT JOIN hostname_types ON ((hostname_types.id = hostnames.name_type)))
  ORDER BY test_areas.name, hosts.ip_address, hostname_types.name_type;



--
-- Name: view_hosts_ytfe; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_hosts_ytfe AS
 SELECT view_hosts.host_id,
    view_hosts.test_area_id,
    view_hosts.test_area_name,
    view_hosts.ip_address,
    view_hosts.hostname,
    view_hosts.name_type,
    hi1.value AS finished,
    hi2.value AS owned
   FROM ((view_hosts
     LEFT JOIN view_host_info hi1 ON (((view_hosts.host_id = hi1.host_id) AND ((hi1.key)::text = 'yaptestfe_finished'::text))))
     LEFT JOIN view_host_info hi2 ON (((view_hosts.host_id = hi2.host_id) AND ((hi2.key)::text = 'yaptestfe_owned'::text))));



--
-- Name: view_port_info; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_info AS
 SELECT port_info.id AS port_info_id,
    ports.id AS port_id,
    hosts.id AS host_id,
    hosts.ip_address,
    hosts.test_area_id,
    test_areas.name AS test_area_name,
    ports.port,
    transport_protocols.name AS transport_protocol,
    port_keys.name AS port_info_key,
    port_info.value
   FROM (((((port_info
     JOIN port_keys ON ((port_info.key_id = port_keys.id)))
     JOIN ports ON ((port_info.port_id = ports.id)))
     JOIN hosts ON ((ports.host_id = hosts.id)))
     JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY hosts.ip_address, ports.port, transport_protocols.name, port_keys.name;



--
-- Name: view_http_banners; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_http_banners AS
 SELECT view_port_info.ip_address,
    view_port_info.port,
    view_port_info.transport_protocol,
    view_port_info.port_info_key,
    view_port_info.value
   FROM view_port_info
  WHERE ((view_port_info.port IN ( SELECT DISTINCT view_port_info_1.port
           FROM view_port_info view_port_info_1
          WHERE ((view_port_info_1.port_info_key = 'nmap_service_name'::text) AND (view_port_info_1.value = 'http'::text))
          ORDER BY view_port_info_1.port)) AND (view_port_info.port_info_key = 'nmap_service_version'::text));



--
-- Name: view_icmp; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_icmp AS
 SELECT test_areas.name AS test_area_name,
    test_areas.id AS test_area_id,
    hosts.ip_address,
    icmp.host_id,
    icmp.icmp_type,
    icmp.icmp_code,
    icmp_names.name AS icmp_name
   FROM (((icmp
     JOIN icmp_names ON (((icmp.icmp_type = icmp_names.icmp_type) AND (icmp.icmp_code = icmp_names.icmp_code))))
     JOIN hosts ON ((icmp.host_id = hosts.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)));



--
-- Name: view_port_info_ssl; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_info_ssl AS
 SELECT view_port_info.port_info_id,
    view_port_info.port_id,
    view_port_info.host_id,
    view_port_info.ip_address,
    view_port_info.test_area_id,
    view_port_info.test_area_name,
    view_port_info.port,
    view_port_info.transport_protocol,
    view_port_info.port_info_key,
    view_port_info.value,
    v2.value AS nmap_service_tunnel
   FROM (view_port_info
     LEFT JOIN view_port_info v2 ON (((view_port_info.port_id = v2.port_id) AND ((v2.port_info_key = 'amap_service_tunnel'::text) OR (v2.port_info_key = 'nmap_service_tunnel'::text)))))
  WHERE ((view_port_info.port_info_key <> 'nmap_service_tunnel'::text) AND (view_port_info.port_info_key <> 'amap_service_tunnel'::text));



--
-- Name: view_insecure_protos; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_insecure_protos AS
 SELECT DISTINCT
        CASE
            WHEN (view_port_info.port_info_key = 'nmap_service_name'::text) THEN view_port_info.value
            ELSE NULL::text
        END AS nmap_service_name,
    view_port_info.test_area_id,
    view_port_info.test_area_name,
    view_port_info.host_id,
    view_port_info.ip_address,
    view_port_info.port_id,
    view_port_info.port,
    view_port_info.transport_protocol
   FROM view_port_info
  WHERE ((((((((((((view_port_info.port_info_key = 'nmap_service_name'::text) AND ((((view_port_info.value = 'microsoft-rdp'::text) OR (view_port_info.value = 'http'::text)) OR (view_port_info.value = 'ms-sql-s'::text)) OR (view_port_info.value = 'ldap'::text))) OR (view_port_info.port = 21)) OR (view_port_info.port = 23)) OR (view_port_info.port = 512)) OR (view_port_info.port = 513)) OR (view_port_info.port = 514)) OR (view_port_info.port = 161)) OR (view_port_info.port = 110)) OR (view_port_info.port = 143)) OR (view_port_info.port = 69)) OR (view_port_info.port = 177))
EXCEPT
 SELECT view_port_info_ssl.value AS nmap_service_name,
    view_port_info_ssl.test_area_id,
    view_port_info_ssl.test_area_name,
    view_port_info_ssl.host_id,
    view_port_info_ssl.ip_address,
    view_port_info_ssl.port_id,
    view_port_info_ssl.port,
    view_port_info_ssl.transport_protocol
   FROM view_port_info_ssl
  WHERE (((view_port_info_ssl.nmap_service_tunnel = 'ssl'::text) AND (view_port_info_ssl.port_info_key = 'nmap_service_name'::text)) AND ((view_port_info_ssl.value = 'http'::text) OR (view_port_info_ssl.value = 'ldap'::text)))
  ORDER BY 1, 7, 5;



--
-- Name: view_interfaces; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_interfaces AS
 SELECT test_areas.name,
    interfaces.box_id,
    interfaces.ip_address,
    interfaces.icmp_ttl,
    boxes.label,
    interfaces.netmask
   FROM ((interfaces
     JOIN boxes ON ((interfaces.box_id = boxes.id)))
     JOIN test_areas ON ((test_areas.id = boxes.test_area_id)));



--
-- Name: view_issues; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_issues AS
 SELECT test_areas.id AS test_area_id,
    test_areas.name AS test_area_name,
    issues.id AS issue_id,
    issues.shortname AS issue_shortname,
    hosts.id AS host_id,
    hosts.ip_address,
    ports.id AS port_id,
    ports.port,
    ports.transport_protocol_id,
    transport_protocols.name AS transport_protocol_name
   FROM (((((issues_to_ports
     JOIN issues ON ((issues.id = issues_to_ports.issue_id)))
     JOIN ports ON ((ports.id = issues_to_ports.port_id)))
     JOIN hosts ON ((hosts.id = ports.host_id)))
     JOIN test_areas ON ((test_areas.id = hosts.test_area_id)))
     JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
UNION
 SELECT test_areas.id AS test_area_id,
    test_areas.name AS test_area_name,
    issues.id AS issue_id,
    issues.shortname AS issue_shortname,
    hosts.id AS host_id,
    hosts.ip_address,
    NULL::integer AS port_id,
    NULL::integer AS port,
    NULL::integer AS transport_protocol_id,
    NULL::character varying AS transport_protocol_name
   FROM (((issues_to_hosts
     JOIN issues ON ((issues.id = issues_to_hosts.issue_id)))
     JOIN hosts ON ((hosts.id = issues_to_hosts.host_id)))
     JOIN test_areas ON ((test_areas.id = hosts.test_area_id)))
UNION
 SELECT test_areas.id AS test_area_id,
    test_areas.name AS test_area_name,
    issues.id AS issue_id,
    issues.shortname AS issue_shortname,
    NULL::integer AS host_id,
    NULL::inet AS ip_address,
    NULL::integer AS port_id,
    NULL::integer AS port,
    NULL::integer AS transport_protocol_id,
    NULL::character varying AS transport_protocol_name
   FROM ((issues_to_testareas
     JOIN issues ON ((issues.id = issues_to_testareas.issue_id)))
     JOIN test_areas ON ((test_areas.id = issues_to_testareas.testarea_id)));



--
-- Name: view_mac_addresses; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_mac_addresses AS
 SELECT test_areas.name AS test_area_name,
    test_areas.id AS test_area_id,
    hosts.ip_address,
    hosts.id AS host_id,
    mac_addresses.mac_address,
    view_host_info.value AS mac_vendor
   FROM ((((hosts_to_mac_addresses
     JOIN mac_addresses ON ((hosts_to_mac_addresses.mac_address_id = mac_addresses.id)))
     JOIN hosts ON ((hosts_to_mac_addresses.host_id = hosts.id)))
     JOIN test_areas ON ((test_areas.id = hosts.test_area_id)))
     LEFT JOIN view_host_info ON (((hosts.id = view_host_info.host_id) AND ((view_host_info.key)::text = 'mac_vendor'::text))));



--
-- Name: view_ports; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_ports AS
 SELECT ports.id AS port_id,
    hosts.id AS host_id,
    hosts.ip_address,
    hosts.test_area_id,
    ports.port,
    test_areas.name AS test_area_name,
    transport_protocols.name AS transport_protocol
   FROM (((hosts
     JOIN ports ON ((hosts.id = ports.host_id)))
     JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY hosts.ip_address, transport_protocols.name, ports.port;



--
-- Name: view_nmap_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_nmap_info AS
 SELECT p1.value,
    p1.port_info_id,
    p1.port_info_key,
    vp.port_id,
    vp.host_id,
    vp.ip_address,
    vp.test_area_id,
    vp.test_area_name,
    vp.port,
    vp.transport_protocol,
    p1.value AS nmap_service,
    p2.value AS nmap_version
   FROM ((view_ports vp
     LEFT JOIN view_port_info p1 ON (((vp.port_id = p1.port_id) AND (p1.port_info_key = 'nmap_service_name'::text))))
     LEFT JOIN view_port_info p2 ON (((vp.port_id = p2.port_id) AND (p2.port_info_key = 'nmap_service_version'::text))));



--
-- Name: view_os; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_os AS
 SELECT test_areas.name,
    hosts.ip_address,
    host_info.value
   FROM (((hosts
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
     LEFT JOIN host_info ON ((host_info.host_id = hosts.id)))
     LEFT JOIN host_keys ON ((host_info.host_key_id = host_keys.id)))
  WHERE ((host_keys.name IS NULL) OR ((host_keys.name)::text = 'os'::text))
  ORDER BY test_areas.name, hosts.ip_address;



--
-- Name: view_password_hashes; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_password_hashes AS
 SELECT view_credentials.test_area_id,
    view_credentials.host_id,
    view_credentials.test_area_name,
    view_credentials.credential_type_name,
    view_credentials.ip_address,
    view_credentials.port,
    view_credentials.transport_protocol_name,
    view_credentials.username,
    view_credentials.password,
    view_credentials.password_hash,
    view_credentials.password_hash_type_name
   FROM view_credentials
  WHERE (view_credentials.password_hash IS NOT NULL);



--
-- Name: view_port_info_progress; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_port_info_progress AS
 SELECT port_info.id AS port_info_id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    commands.name AS command,
    progress_states.name AS state
   FROM ((((((port_info_progress
     JOIN port_info ON ((port_info_progress.port_info_id = port_info.id)))
     JOIN ports ON ((ports.id = port_info.port_id)))
     JOIN hosts ON ((ports.host_id = hosts.id)))
     JOIN commands ON ((port_info_progress.command_id = commands.id)))
     JOIN progress_states ON ((progress_states.id = port_info_progress.state_id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, commands.name, hosts.ip_address;



--
-- Name: view_port_issues; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_issues AS
 SELECT issues_to_ports.id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    ports.port,
    transport_protocols.name AS transport_protocol_name,
    issues.shortname AS issue
   FROM (((((issues_to_ports
     JOIN ports ON ((ports.id = issues_to_ports.port_id)))
     JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
     JOIN hosts ON ((ports.host_id = hosts.id)))
     JOIN issues ON ((issues_to_ports.issue_id = issues.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, hosts.ip_address, issues.shortname;



--
-- Name: view_port_progress; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_progress AS
 SELECT ports.id AS port_id,
    hosts.ip_address,
    hosts.test_area_id,
    ports.port,
    test_areas.name AS test_area_name,
    transport_protocols.name AS transport_protocol_name,
    commands.name AS command,
    progress_states.name AS state
   FROM ((((((port_progress
     JOIN ports ON ((port_progress.port_id = ports.id)))
     JOIN commands ON ((port_progress.command_id = commands.id)))
     JOIN progress_states ON ((progress_states.id = port_progress.state_id)))
     JOIN hosts ON ((hosts.id = ports.host_id)))
     JOIN transport_protocols ON ((ports.transport_protocol_id = transport_protocols.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
  ORDER BY test_areas.name, commands.name, hosts.ip_address, ports.port, transport_protocols.name;



--
-- Name: view_port_summary; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_summary AS
 SELECT count(1) AS count,
    view_ports.port,
    view_ports.transport_protocol,
    view_ports.test_area_id,
    view_ports.test_area_name
   FROM view_ports
  GROUP BY view_ports.port, view_ports.transport_protocol, view_ports.test_area_id, view_ports.test_area_name
  ORDER BY count(1) DESC, view_ports.port, view_ports.transport_protocol;



--
-- Name: view_port_summary_by_test_area; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_port_summary_by_test_area AS
 SELECT count(1) AS count,
    view_ports.test_area_id,
    view_ports.test_area_name,
    view_ports.port,
    view_ports.transport_protocol
   FROM view_ports
  GROUP BY view_ports.test_area_id, view_ports.test_area_name, view_ports.port, view_ports.transport_protocol
  ORDER BY view_ports.test_area_id, view_ports.port DESC, view_ports.transport_protocol DESC;



--
-- Name: view_ssh_banners; Type: VIEW; Schema: public; Owner: yaptest
--

CREATE VIEW view_ssh_banners AS
 SELECT view_port_info.ip_address,
    view_port_info.port,
    view_port_info.transport_protocol,
    view_port_info.port_info_key,
    view_port_info.value
   FROM view_port_info
  WHERE ((view_port_info.port_info_key = 'nmap_service_version'::text) AND ((view_port_info.ip_address, view_port_info.port, (view_port_info.transport_protocol)::text) IN ( SELECT view_port_info_1.ip_address,
            view_port_info_1.port,
            view_port_info_1.transport_protocol
           FROM view_port_info view_port_info_1
          WHERE ((view_port_info_1.port_info_key = 'nmap_service_name'::text) AND (view_port_info_1.value = 'ssh'::text)))));



--
-- Name: view_topology; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_topology AS
 SELECT i1.hop AS hop_number,
    i2.hop AS prev_hop_number,
    test_areas.name AS test_area_name,
    boxes.test_area_id,
    i1.ip_address,
    i2.ip_address AS prev_hop_ip,
    i1.id AS interface_id,
    i2.id AS prev_hop_interface_id
   FROM ((((topology
     JOIN interfaces i1 ON ((topology.interface_id = i1.id)))
     JOIN interfaces i2 ON ((topology.prev_hop_interface_id = i2.id)))
     JOIN boxes ON ((i1.box_id = boxes.id)))
     JOIN test_areas ON ((boxes.test_area_id = test_areas.id)));



--
-- Name: view_windows_host_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW view_windows_host_info AS
 SELECT DISTINCT hosts.id AS host_id,
    test_areas.id AS test_area_id,
    test_areas.name AS test_area_name,
    hosts.ip_address,
    hostnames.name AS hostname,
    v1.value AS os,
    v2.value AS dom_name,
        CASE
            WHEN (v3.value IS NULL) THEN 'N'::text
            ELSE 'Y'::text
        END AS dc,
    v4.value AS member_of,
    v5.value AS smb_server_version,
    v6.value AS device_info,
    v7.value AS domain_sid,
    v8.value AS pwd_complexity_flags,
    v9.value AS lockout_threshold,
    v10.value AS lockout_duration,
    v11.value AS reset_lockout_ctr,
    v12.value AS windows_long_dom
   FROM (((((((((((((((((host_info
     JOIN hosts ON ((host_info.host_id = hosts.id)))
     JOIN hostnames ON ((host_info.host_id = hostnames.host_id)))
     JOIN hostname_types ON ((hostnames.name_type = hostname_types.id)))
     JOIN host_keys ON ((host_info.host_key_id = host_keys.id)))
     JOIN test_areas ON ((hosts.test_area_id = test_areas.id)))
     LEFT JOIN view_host_info v1 ON (((hosts.id = v1.host_id) AND ((v1.key)::text = 'os'::text))))
     LEFT JOIN view_host_info v2 ON (((hosts.id = v2.host_id) AND ((v2.key)::text = 'windows_domwkg'::text))))
     LEFT JOIN view_host_info v3 ON (((hosts.id = v3.host_id) AND ((v3.key)::text = 'windows_dc'::text))))
     LEFT JOIN view_host_info v4 ON (((hosts.id = v4.host_id) AND ((v4.key)::text = 'windows_member_of'::text))))
     LEFT JOIN view_host_info v5 ON (((hosts.id = v5.host_id) AND ((v5.key)::text = 'smb_server'::text))))
     LEFT JOIN view_host_info v6 ON (((hosts.id = v6.host_id) AND ((v6.key)::text = 'device_info'::text))))
     LEFT JOIN view_host_info v7 ON (((hosts.id = v7.host_id) AND ((v7.key)::text = 'windows_domain_sid'::text))))
     LEFT JOIN view_host_info v8 ON (((hosts.id = v8.host_id) AND ((v8.key)::text = 'windows_password_complexity'::text))))
     LEFT JOIN view_host_info v9 ON (((hosts.id = v9.host_id) AND ((v9.key)::text = 'windows_acct_lockout_threshold'::text))))
     LEFT JOIN view_host_info v10 ON (((hosts.id = v10.host_id) AND ((v10.key)::text = 'windows_acct_lockout_duration'::text))))
     LEFT JOIN view_host_info v11 ON (((hosts.id = v11.host_id) AND ((v11.key)::text = 'windows_reset_acct_lockout_ctr'::text))))
     LEFT JOIN view_host_info v12 ON (((hosts.id = v12.host_id) AND ((v12.key)::text = 'windows_long_dom'::text))))
  WHERE ((hostname_types.name_type)::text = 'windows_hostname'::text)
  ORDER BY hosts.id, test_areas.id, test_areas.name, hosts.ip_address, hostnames.name, v1.value, v2.value,
        CASE
            WHEN (v3.value IS NULL) THEN 'N'::text
            ELSE 'Y'::text
        END, v4.value, v5.value, v6.value, v7.value, v8.value, v9.value, v10.value, v11.value, v12.value;



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY app_protocols ALTER COLUMN id SET DEFAULT nextval('app_protocols_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY boxes ALTER COLUMN id SET DEFAULT nextval('boxes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY command_log ALTER COLUMN id SET DEFAULT nextval('command_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY command_status ALTER COLUMN id SET DEFAULT nextval('command_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY commands ALTER COLUMN id SET DEFAULT nextval('commands_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY credential_types ALTER COLUMN id SET DEFAULT nextval('credential_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY credentials ALTER COLUMN id SET DEFAULT nextval('credentials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY credentials_progress ALTER COLUMN id SET DEFAULT nextval('credentials_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY custom_entities ALTER COLUMN id SET DEFAULT nextval('custom_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY group_memberships ALTER COLUMN id SET DEFAULT nextval('group_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY host_info ALTER COLUMN id SET DEFAULT nextval('host_info_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY host_info_progress ALTER COLUMN id SET DEFAULT nextval('host_info_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY host_keys ALTER COLUMN id SET DEFAULT nextval('host_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY host_progress ALTER COLUMN id SET DEFAULT nextval('host_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hostname_progress ALTER COLUMN id SET DEFAULT nextval('hostname_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY hostname_types ALTER COLUMN id SET DEFAULT nextval('hostname_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY hostnames ALTER COLUMN id SET DEFAULT nextval('hostnames_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY hosts_to_mac_addresses ALTER COLUMN id SET DEFAULT nextval('hosts_to_mac_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY icmp ALTER COLUMN id SET DEFAULT nextval('icmp_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY icmp_names ALTER COLUMN id SET DEFAULT nextval('icmp_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY interfaces ALTER COLUMN id SET DEFAULT nextval('interfaces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issue_ratings ALTER COLUMN id SET DEFAULT nextval('issue_ratings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issue_sources ALTER COLUMN id SET DEFAULT nextval('issue_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issues_to_custom_entities ALTER COLUMN id SET DEFAULT nextval('issues_to_custom_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issues_to_hosts ALTER COLUMN id SET DEFAULT nextval('issues_to_hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issues_to_ports ALTER COLUMN id SET DEFAULT nextval('issues_to_ports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY issues_to_testareas ALTER COLUMN id SET DEFAULT nextval('issues_to_testareas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY mac_addresses ALTER COLUMN id SET DEFAULT nextval('mac_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY password_hash_types ALTER COLUMN id SET DEFAULT nextval('password_hash_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY password_types ALTER COLUMN id SET DEFAULT nextval('password_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY port_info ALTER COLUMN id SET DEFAULT nextval('port_info_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY port_info_progress ALTER COLUMN id SET DEFAULT nextval('port_info_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY port_keys ALTER COLUMN id SET DEFAULT nextval('port_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY port_progress ALTER COLUMN id SET DEFAULT nextval('port_progress_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY ports ALTER COLUMN id SET DEFAULT nextval('ports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY ports_to_app_protocols ALTER COLUMN id SET DEFAULT nextval('ports_to_app_protocols_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY progress_states ALTER COLUMN id SET DEFAULT nextval('progress_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY test_areas ALTER COLUMN id SET DEFAULT nextval('test_areas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY topology ALTER COLUMN id SET DEFAULT nextval('topology_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: yaptest
--

ALTER TABLE ONLY transport_protocols ALTER COLUMN id SET DEFAULT nextval('transport_protocols_id_seq'::regclass);


--
-- Data for Name: app_protocols; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY app_protocols (id, name, amap_name, nmap_name) FROM stdin;
\.


--
-- Name: app_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('app_protocols_id_seq', 1, false);


--
-- Data for Name: boxes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY boxes (id, test_area_id, label) FROM stdin;
\.


--
-- Name: boxes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('boxes_id_seq', 1, false);


--
-- Data for Name: command_log; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY command_log (id, "time", command, command_status_id) FROM stdin;
\.


--
-- Name: command_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('command_log_id_seq', 1, false);


--
-- Data for Name: command_status; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY command_status (id, name) FROM stdin;
\.


--
-- Name: command_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('command_status_id_seq', 1, false);


--
-- Data for Name: commands; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY commands (id, name, hash) FROM stdin;
\.


--
-- Name: commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('commands_id_seq', 1, false);


--
-- Data for Name: credential_types; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY credential_types (id, name, description) FROM stdin;
\.


--
-- Name: credential_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('credential_types_id_seq', 1, false);


--
-- Data for Name: credentials; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY credentials (id, uid, host_id, port_id, credential_type_id, domain, username, password, password_hash, password_hash_type_id, password_half1, password_half2, hash_half1, hash_half2, "group") FROM stdin;
\.


--
-- Name: credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('credentials_id_seq', 1, false);


--
-- Data for Name: credentials_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY credentials_progress (id, credential_id, command_id, state_id) FROM stdin;
\.


--
-- Name: credentials_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('credentials_progress_id_seq', 1, false);


--
-- Data for Name: custom_entities; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY custom_entities (id, name, description) FROM stdin;
\.


--
-- Name: custom_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('custom_entities_id_seq', 1, false);


--
-- Data for Name: group_memberships; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY group_memberships (id, group_id, member_id) FROM stdin;
\.


--
-- Name: group_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('group_memberships_id_seq', 1, false);


--
-- Data for Name: host_info; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY host_info (id, host_id, host_key_id, value) FROM stdin;
\.


--
-- Name: host_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('host_info_id_seq', 1, false);


--
-- Data for Name: host_info_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY host_info_progress (id, host_info_id, command_id, state_id) FROM stdin;
\.


--
-- Name: host_info_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('host_info_progress_id_seq', 1, false);


--
-- Data for Name: host_keys; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY host_keys (id, name, description) FROM stdin;
\.


--
-- Name: host_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('host_keys_id_seq', 1, false);


--
-- Data for Name: host_progress; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY host_progress (id, host_id, command_id, state_id) FROM stdin;
\.


--
-- Name: host_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('host_progress_id_seq', 1, false);


--
-- Data for Name: hostname_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY hostname_progress (id, hostname_id, command_id, state_id) FROM stdin;
\.


--
-- Name: hostname_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('hostname_progress_id_seq', 1, false);


--
-- Data for Name: hostname_types; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY hostname_types (id, name_type) FROM stdin;
\.


--
-- Name: hostname_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('hostname_types_id_seq', 1, false);


--
-- Data for Name: hostnames; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY hostnames (id, name_type, name, host_id) FROM stdin;
\.


--
-- Name: hostnames_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('hostnames_id_seq', 1, false);


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY hosts (id, ip_address, test_area_id) FROM stdin;
\.


--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('hosts_id_seq', 79, true);


--
-- Data for Name: hosts_to_mac_addresses; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY hosts_to_mac_addresses (id, mac_address_id, host_id) FROM stdin;
\.


--
-- Name: hosts_to_mac_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('hosts_to_mac_addresses_id_seq', 39, true);


--
-- Data for Name: icmp; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY icmp (id, icmp_type, icmp_code, host_id) FROM stdin;
\.


--
-- Name: icmp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('icmp_id_seq', 34, true);


--
-- Data for Name: icmp_names; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY icmp_names (id, icmp_type, icmp_code, name) FROM stdin;
1	0	0	Echo Reply
2	8	0	Echo Request
3	13	0	Timestamp Request
4	14	0	Timestamp Reply
5	16	0	Information Reply
6	15	0	Information Request
7	17	0	Address Mask Request
8	18	0	Address Mask Reply
\.


--
-- Name: icmp_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('icmp_names_id_seq', 8, true);


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY interfaces (id, box_id, ip_address, icmp_ttl, netmask, hop) FROM stdin;
\.


--
-- Name: interfaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('interfaces_id_seq', 1, false);


--
-- Data for Name: issue_ratings; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issue_ratings (id, name, description) FROM stdin;
\.


--
-- Name: issue_ratings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issue_ratings_id_seq', 3, true);


--
-- Data for Name: issue_sources; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issue_sources (id, name, description) FROM stdin;
\.


--
-- Name: issue_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issue_sources_id_seq', 1, true);


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issues (id, shortname, title, description, rating, source) FROM stdin;
\.


--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issues_id_seq', 2, true);


--
-- Data for Name: issues_to_custom_entities; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issues_to_custom_entities (id, issue_id, entity_id) FROM stdin;
\.


--
-- Name: issues_to_custom_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issues_to_custom_entities_id_seq', 1, false);


--
-- Data for Name: issues_to_hosts; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issues_to_hosts (id, issue_id, host_id) FROM stdin;
\.


--
-- Name: issues_to_hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issues_to_hosts_id_seq', 1, false);


--
-- Data for Name: issues_to_ports; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issues_to_ports (id, issue_id, port_id) FROM stdin;
\.


--
-- Name: issues_to_ports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issues_to_ports_id_seq', 1, false);


--
-- Data for Name: issues_to_testareas; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY issues_to_testareas (id, issue_id, testarea_id) FROM stdin;
\.


--
-- Name: issues_to_testareas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('issues_to_testareas_id_seq', 1, false);


--
-- Data for Name: mac_addresses; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY mac_addresses (id, mac_address) FROM stdin;
\.


--
-- Name: mac_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('mac_addresses_id_seq', 52, true);


--
-- Data for Name: password_hash_types; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY password_hash_types (id, name, description) FROM stdin;
\.


--
-- Name: password_hash_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('password_hash_types_id_seq', 1, false);


--
-- Data for Name: password_types; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY password_types (id, name, description) FROM stdin;
\.


--
-- Name: password_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('password_types_id_seq', 1, true);


--
-- Data for Name: port_info; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY port_info (id, port_id, key_id, value) FROM stdin;
\.


--
-- Name: port_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('port_info_id_seq', 1, false);


--
-- Data for Name: port_info_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY port_info_progress (id, port_info_id, command_id, state_id) FROM stdin;
\.


--
-- Name: port_info_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('port_info_progress_id_seq', 1, false);


--
-- Data for Name: port_keys; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY port_keys (id, name, description) FROM stdin;
\.


--
-- Name: port_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('port_keys_id_seq', 4, true);


--
-- Data for Name: port_progress; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY port_progress (id, port_id, command_id, state_id) FROM stdin;
\.


--
-- Name: port_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('port_progress_id_seq', 1, false);


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY ports (id, transport_protocol_id, port, host_id) FROM stdin;
\.


--
-- Name: ports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('ports_id_seq', 311, true);


--
-- Data for Name: ports_to_app_protocols; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY ports_to_app_protocols (id, port_id, app_protocol_id, layer_no) FROM stdin;
\.


--
-- Name: ports_to_app_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('ports_to_app_protocols_id_seq', 1, false);


--
-- Data for Name: progress_states; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY progress_states (id, name, description) FROM stdin;
\.


--
-- Name: progress_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('progress_states_id_seq', 1, false);


--
-- Data for Name: test_areas; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY test_areas (id, name, description) FROM stdin;
\.


--
-- Name: test_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('test_areas_id_seq', 1, false);


--
-- Data for Name: topology; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY topology (id, interface_id, prev_hop_interface_id, comment) FROM stdin;
\.


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('topology_id_seq', 1, false);


--
-- Data for Name: transport_protocols; Type: TABLE DATA; Schema: public; Owner: yaptest
--

COPY transport_protocols (id, name) FROM stdin;
1	TCP
2	UDP
\.


--
-- Name: transport_protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yaptest
--

SELECT pg_catalog.setval('transport_protocols_id_seq', 2, true);


--
-- Name: app_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY app_protocols
    ADD CONSTRAINT app_protocols_pkey PRIMARY KEY (id);


--
-- Name: boxes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY boxes
    ADD CONSTRAINT boxes_pkey PRIMARY KEY (id);


--
-- Name: command_log_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY command_log
    ADD CONSTRAINT command_log_pkey PRIMARY KEY (id);


--
-- Name: command_status_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY command_status
    ADD CONSTRAINT command_status_pkey PRIMARY KEY (id);


--
-- Name: commands_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- Name: credential_types_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY credential_types
    ADD CONSTRAINT credential_types_pkey PRIMARY KEY (id);


--
-- Name: credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY credentials
    ADD CONSTRAINT credentials_pkey PRIMARY KEY (id);


--
-- Name: credentials_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY credentials_progress
    ADD CONSTRAINT credentials_progress_pkey PRIMARY KEY (id);


--
-- Name: custom_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY custom_entities
    ADD CONSTRAINT custom_entities_pkey PRIMARY KEY (id);


--
-- Name: group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: host_info_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY host_info
    ADD CONSTRAINT host_info_pkey PRIMARY KEY (id);


--
-- Name: host_info_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY host_info_progress
    ADD CONSTRAINT host_info_progress_pkey PRIMARY KEY (id);


--
-- Name: host_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY host_keys
    ADD CONSTRAINT host_keys_pkey PRIMARY KEY (id);


--
-- Name: host_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY host_progress
    ADD CONSTRAINT host_progress_pkey PRIMARY KEY (id);


--
-- Name: hostname_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY hostname_progress
    ADD CONSTRAINT hostname_progress_pkey PRIMARY KEY (id);


--
-- Name: hostname_types_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY hostname_types
    ADD CONSTRAINT hostname_types_pkey PRIMARY KEY (id);


--
-- Name: hostnames_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY hostnames
    ADD CONSTRAINT hostnames_pkey PRIMARY KEY (id);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: hosts_to_mac_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY hosts_to_mac_addresses
    ADD CONSTRAINT hosts_to_mac_addresses_pkey PRIMARY KEY (id);


--
-- Name: icmp_names_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY icmp_names
    ADD CONSTRAINT icmp_names_pkey PRIMARY KEY (id);


--
-- Name: icmp_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY icmp
    ADD CONSTRAINT icmp_pkey PRIMARY KEY (id);


--
-- Name: interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (id);


--
-- Name: issue_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issue_ratings
    ADD CONSTRAINT issue_ratings_pkey PRIMARY KEY (id);


--
-- Name: issue_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issue_sources
    ADD CONSTRAINT issue_sources_pkey PRIMARY KEY (id);


--
-- Name: issues_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: issues_to_custom_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issues_to_custom_entities
    ADD CONSTRAINT issues_to_custom_entities_pkey PRIMARY KEY (id);


--
-- Name: issues_to_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issues_to_hosts
    ADD CONSTRAINT issues_to_hosts_pkey PRIMARY KEY (id);


--
-- Name: issues_to_ports_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issues_to_ports
    ADD CONSTRAINT issues_to_ports_pkey PRIMARY KEY (id);


--
-- Name: issues_to_testareas_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY issues_to_testareas
    ADD CONSTRAINT issues_to_testareas_pkey PRIMARY KEY (id);


--
-- Name: mac_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY mac_addresses
    ADD CONSTRAINT mac_addresses_pkey PRIMARY KEY (id);


--
-- Name: password_hash_types_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY password_hash_types
    ADD CONSTRAINT password_hash_types_pkey PRIMARY KEY (id);


--
-- Name: password_types_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY password_types
    ADD CONSTRAINT password_types_pkey PRIMARY KEY (id);


--
-- Name: port_info_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY port_info
    ADD CONSTRAINT port_info_pkey PRIMARY KEY (id);


--
-- Name: port_info_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY port_info_progress
    ADD CONSTRAINT port_info_progress_pkey PRIMARY KEY (id);


--
-- Name: port_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY port_keys
    ADD CONSTRAINT port_keys_pkey PRIMARY KEY (id);


--
-- Name: port_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY port_progress
    ADD CONSTRAINT port_progress_pkey PRIMARY KEY (id);


--
-- Name: ports_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- Name: ports_to_app_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY ports_to_app_protocols
    ADD CONSTRAINT ports_to_app_protocols_pkey PRIMARY KEY (id);


--
-- Name: progress_states_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY progress_states
    ADD CONSTRAINT progress_states_pkey PRIMARY KEY (id);


--
-- Name: test_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY test_areas
    ADD CONSTRAINT test_areas_pkey PRIMARY KEY (id);


--
-- Name: topology_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY topology
    ADD CONSTRAINT topology_pkey PRIMARY KEY (id);


--
-- Name: transport_protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: yaptest; Tablespace: 
--

ALTER TABLE ONLY transport_protocols
    ADD CONSTRAINT transport_protocols_pkey PRIMARY KEY (id);


--
-- Name: credspeedup; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX credspeedup ON credentials USING btree (host_id, port_id, domain, username, password_hash_type_id, credential_type_id);


--
-- Name: credspeedup2; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX credspeedup2 ON credentials USING btree (hash_half2, password_hash_type_id);


--
-- Name: credspeedup3; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX credspeedup3 ON credentials USING btree (hash_half1, password_hash_type_id);


--
-- Name: credspeedup4; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX credspeedup4 ON credentials USING btree (password, hash_half1, hash_half2, password_hash_type_id);


--
-- Name: credspeedup5; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX credspeedup5 ON credentials USING btree (password_hash, password_hash_type_id);


--
-- Name: icmp_names_uidx; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX icmp_names_uidx ON icmp USING btree (icmp_type, icmp_code);


--
-- Name: icmp_uidx; Type: INDEX; Schema: public; Owner: yaptest; Tablespace: 
--

CREATE INDEX icmp_uidx ON icmp USING btree (icmp_type, icmp_code, host_id);


--
-- Name: boxes_test_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY boxes
    ADD CONSTRAINT boxes_test_area_id_fkey FOREIGN KEY (test_area_id) REFERENCES test_areas(id);


--
-- Name: credentials_progress_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY credentials_progress
    ADD CONSTRAINT credentials_progress_command_id_fkey FOREIGN KEY (command_id) REFERENCES commands(id);


--
-- Name: credentials_progress_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY credentials_progress
    ADD CONSTRAINT credentials_progress_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES credentials(id);


--
-- Name: credentials_progress_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY credentials_progress
    ADD CONSTRAINT credentials_progress_state_id_fkey FOREIGN KEY (state_id) REFERENCES progress_states(id);


--
-- Name: host_info_progress_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY host_info_progress
    ADD CONSTRAINT host_info_progress_command_id_fkey FOREIGN KEY (command_id) REFERENCES commands(id);


--
-- Name: host_info_progress_host_info_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY host_info_progress
    ADD CONSTRAINT host_info_progress_host_info_id_fkey FOREIGN KEY (host_info_id) REFERENCES host_info(id);


--
-- Name: host_info_progress_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY host_info_progress
    ADD CONSTRAINT host_info_progress_state_id_fkey FOREIGN KEY (state_id) REFERENCES progress_states(id);


--
-- Name: hostname_progress_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hostname_progress
    ADD CONSTRAINT hostname_progress_command_id_fkey FOREIGN KEY (command_id) REFERENCES commands(id);


--
-- Name: hostname_progress_hostname_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hostname_progress
    ADD CONSTRAINT hostname_progress_hostname_id_fkey FOREIGN KEY (hostname_id) REFERENCES hostnames(id);


--
-- Name: hostname_progress_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hostname_progress
    ADD CONSTRAINT hostname_progress_state_id_fkey FOREIGN KEY (state_id) REFERENCES progress_states(id);


--
-- Name: interfaces_box_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT interfaces_box_id_fkey FOREIGN KEY (box_id) REFERENCES boxes(id);


--
-- Name: port_info_progress_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY port_info_progress
    ADD CONSTRAINT port_info_progress_command_id_fkey FOREIGN KEY (command_id) REFERENCES commands(id);


--
-- Name: port_info_progress_port_info_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY port_info_progress
    ADD CONSTRAINT port_info_progress_port_info_id_fkey FOREIGN KEY (port_info_id) REFERENCES port_info(id);


--
-- Name: port_info_progress_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY port_info_progress
    ADD CONSTRAINT port_info_progress_state_id_fkey FOREIGN KEY (state_id) REFERENCES progress_states(id);


--
-- Name: topology_interface_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY topology
    ADD CONSTRAINT topology_interface_id_fkey FOREIGN KEY (interface_id) REFERENCES interfaces(id);


--
-- Name: topology_prev_hop_interface_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY topology
    ADD CONSTRAINT topology_prev_hop_interface_id_fkey FOREIGN KEY (prev_hop_interface_id) REFERENCES interfaces(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--



--
-- Name: app_protocols; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: boxes; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: boxes_id_seq; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: command_log; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: command_log_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: command_status; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: command_status_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: commands; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: commands_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: credential_types; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: credential_types_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: credentials; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: credentials_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: credentials_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: group_memberships; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: group_memberships_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_info; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_info_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_info_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: host_keys; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_keys_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_progress; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: host_progress_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: hostname_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: hostname_types; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: hostnames; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: hosts; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: hosts_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: hosts_to_mac_addresses; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: icmp; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: icmp_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: icmp_names; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: interfaces; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: interfaces_id_seq; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: issues; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: issues_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: issues_to_hosts; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: issues_to_hosts_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: issues_to_ports; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: issues_to_ports_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: mac_addresses; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: password_hash_types; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: password_hash_types_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: password_types; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: password_types_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_info; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_info_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_info_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: port_info_progress_id_seq; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: port_keys; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_keys_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_progress; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: port_progress_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: ports; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: ports_to_app_protocols; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: progress_states; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: progress_states_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: test_areas; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: test_areas_id_seq; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: topology; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: topology_id_seq; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: transport_protocols; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_command_log; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_credentials; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_groups; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_host_info; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_host_info_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_host_issues; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_host_progress; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_hosts; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_hosts_ytfe; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_port_info; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_http_banners; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_icmp; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_port_info_ssl; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_insecure_protos; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_interfaces; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_issues; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_mac_addresses; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_ports; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_nmap_info; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_os; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_password_hashes; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_port_info_progress; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_port_issues; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_port_progress; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_port_summary; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_port_summary_by_test_area; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_ssh_banners; Type: ACL; Schema: public; Owner: yaptest
--



--
-- Name: view_topology; Type: ACL; Schema: public; Owner: postgres
--



--
-- Name: view_windows_host_info; Type: ACL; Schema: public; Owner: postgres
--



--
-- PostgreSQL database dump complete
--

