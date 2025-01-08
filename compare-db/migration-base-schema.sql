--
-- PostgreSQL database dump
--

-- Dumped from database version 11.16 (Debian 11.16-1.pgdg90+1)
-- Dumped by pg_dump version 11.16 (Debian 11.16-1.pgdg90+1)

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: call_exit_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.call_exit_type AS ENUM (
    'full',
    'closed',
    'joinempty',
    'leaveempty',
    'divert_ca_ratio',
    'divert_waittime',
    'answered',
    'abandoned',
    'timeout'
);


ALTER TYPE public.call_exit_type OWNER TO postgres;

--
-- Name: callerid_mode; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callerid_mode AS ENUM (
    'prepend',
    'overwrite',
    'append'
);


ALTER TYPE public.callerid_mode OWNER TO postgres;

--
-- Name: callerid_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callerid_type AS ENUM (
    'callfilter',
    'incall',
    'group',
    'queue'
);


ALTER TYPE public.callerid_type OWNER TO postgres;

--
-- Name: callfilter_bosssecretary; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callfilter_bosssecretary AS ENUM (
    'bossfirst-serial',
    'bossfirst-simult',
    'secretary-serial',
    'secretary-simult',
    'all'
);


ALTER TYPE public.callfilter_bosssecretary OWNER TO postgres;

--
-- Name: callfilter_callfrom; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callfilter_callfrom AS ENUM (
    'internal',
    'external',
    'all'
);


ALTER TYPE public.callfilter_callfrom OWNER TO postgres;

--
-- Name: callfilter_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callfilter_type AS ENUM (
    'bosssecretary'
);


ALTER TYPE public.callfilter_type OWNER TO postgres;

--
-- Name: callfiltermember_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.callfiltermember_type AS ENUM (
    'user'
);


ALTER TYPE public.callfiltermember_type OWNER TO postgres;

--
-- Name: contextnumbers_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.contextnumbers_type AS ENUM (
    'user',
    'group',
    'queue',
    'meetme',
    'incall'
);


ALTER TYPE public.contextnumbers_type OWNER TO postgres;

--
-- Name: dialaction_action; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dialaction_action AS ENUM (
    'none',
    'endcall:busy',
    'endcall:congestion',
    'endcall:hangup',
    'user',
    'group',
    'queue',
    'voicemail',
    'extension',
    'outcall',
    'application:callbackdisa',
    'application:disa',
    'application:directory',
    'application:faxtomail',
    'application:voicemailmain',
    'application:password',
    'sound',
    'custom',
    'ivr',
    'conference',
    'switchboard',
    'application:custom'
);


ALTER TYPE public.dialaction_action OWNER TO postgres;

--
-- Name: dialaction_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.dialaction_category AS ENUM (
    'callfilter',
    'group',
    'incall',
    'queue',
    'user',
    'ivr',
    'ivr_choice',
    'switchboard'
);


ALTER TYPE public.dialaction_category OWNER TO postgres;

--
-- Name: endpoint_sip_section_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.endpoint_sip_section_type AS ENUM (
    'aor',
    'auth',
    'endpoint',
    'identify',
    'outbound_auth',
    'registration_outbound_auth',
    'registration'
);


ALTER TYPE public.endpoint_sip_section_type OWNER TO postgres;

--
-- Name: extenumbers_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.extenumbers_type AS ENUM (
    'extenfeatures',
    'featuremap',
    'generalfeatures',
    'group',
    'incall',
    'outcall',
    'queue',
    'user',
    'voicemenu',
    'conference',
    'parking'
);


ALTER TYPE public.extenumbers_type OWNER TO postgres;

--
-- Name: generic_bsfilter; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.generic_bsfilter AS ENUM (
    'no',
    'boss',
    'secretary'
);


ALTER TYPE public.generic_bsfilter OWNER TO postgres;

--
-- Name: netiface_family; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.netiface_family AS ENUM (
    'inet',
    'inet6'
);


ALTER TYPE public.netiface_family OWNER TO postgres;

--
-- Name: netiface_method; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.netiface_method AS ENUM (
    'static',
    'dhcp',
    'manual'
);


ALTER TYPE public.netiface_method OWNER TO postgres;

--
-- Name: netiface_networktype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.netiface_networktype AS ENUM (
    'data',
    'voip'
);


ALTER TYPE public.netiface_networktype OWNER TO postgres;

--
-- Name: netiface_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.netiface_type AS ENUM (
    'iface'
);


ALTER TYPE public.netiface_type OWNER TO postgres;

--
-- Name: pickup_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.pickup_category AS ENUM (
    'member',
    'pickup'
);


ALTER TYPE public.pickup_category OWNER TO postgres;

--
-- Name: pickup_membertype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.pickup_membertype AS ENUM (
    'group',
    'queue',
    'user'
);


ALTER TYPE public.pickup_membertype OWNER TO postgres;

--
-- Name: queue_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.queue_category AS ENUM (
    'group',
    'queue'
);


ALTER TYPE public.queue_category OWNER TO postgres;

--
-- Name: queue_monitor_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.queue_monitor_type AS ENUM (
    'no',
    'mixmonitor'
);


ALTER TYPE public.queue_monitor_type OWNER TO postgres;

--
-- Name: queue_statistics; Type: TYPE; Schema: public; Owner: asterisk
--

CREATE TYPE public.queue_statistics AS (
	received_call_count bigint,
	answered_call_count bigint,
	answered_call_in_qos_count bigint,
	abandonned_call_count bigint,
	received_and_done bigint,
	max_hold_time integer,
	mean_hold_time integer
);


ALTER TYPE public.queue_statistics OWNER TO asterisk;

--
-- Name: queuemember_usertype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.queuemember_usertype AS ENUM (
    'agent',
    'user'
);


ALTER TYPE public.queuemember_usertype OWNER TO postgres;

--
-- Name: queuepenaltychange_sign; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.queuepenaltychange_sign AS ENUM (
    '=',
    '+',
    '-'
);


ALTER TYPE public.queuepenaltychange_sign OWNER TO postgres;

--
-- Name: schedule_path_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.schedule_path_type AS ENUM (
    'user',
    'group',
    'queue',
    'incall',
    'outcall',
    'voicemenu'
);


ALTER TYPE public.schedule_path_type OWNER TO postgres;

--
-- Name: schedule_time_mode; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.schedule_time_mode AS ENUM (
    'opened',
    'closed'
);


ALTER TYPE public.schedule_time_mode OWNER TO postgres;

--
-- Name: stat_switchboard_endtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stat_switchboard_endtype AS ENUM (
    'abandoned',
    'completed',
    'forwarded',
    'transferred'
);


ALTER TYPE public.stat_switchboard_endtype OWNER TO postgres;

--
-- Name: trunk_protocol; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.trunk_protocol AS ENUM (
    'sip',
    'iax',
    'sccp',
    'custom'
);


ALTER TYPE public.trunk_protocol OWNER TO postgres;

--
-- Name: usercustom_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usercustom_category AS ENUM (
    'user',
    'trunk'
);


ALTER TYPE public.usercustom_category OWNER TO postgres;

--
-- Name: useriax_amaflags; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_amaflags AS ENUM (
    'default',
    'omit',
    'billing',
    'documentation'
);


ALTER TYPE public.useriax_amaflags OWNER TO postgres;

--
-- Name: useriax_auth; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_auth AS ENUM (
    'plaintext',
    'md5',
    'rsa',
    'plaintext,md5',
    'plaintext,rsa',
    'md5,rsa',
    'plaintext,md5,rsa'
);


ALTER TYPE public.useriax_auth OWNER TO postgres;

--
-- Name: useriax_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_category AS ENUM (
    'user',
    'trunk'
);


ALTER TYPE public.useriax_category OWNER TO postgres;

--
-- Name: useriax_codecpriority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_codecpriority AS ENUM (
    'disabled',
    'host',
    'caller',
    'reqonly'
);


ALTER TYPE public.useriax_codecpriority OWNER TO postgres;

--
-- Name: useriax_encryption; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_encryption AS ENUM (
    'no',
    'yes',
    'aes128'
);


ALTER TYPE public.useriax_encryption OWNER TO postgres;

--
-- Name: useriax_protocol; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_protocol AS ENUM (
    'iax'
);


ALTER TYPE public.useriax_protocol OWNER TO postgres;

--
-- Name: useriax_transfer; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_transfer AS ENUM (
    'no',
    'yes',
    'mediaonly'
);


ALTER TYPE public.useriax_transfer OWNER TO postgres;

--
-- Name: useriax_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.useriax_type AS ENUM (
    'friend',
    'peer',
    'user'
);


ALTER TYPE public.useriax_type OWNER TO postgres;

--
-- Name: usersip_dtmfmode; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_dtmfmode AS ENUM (
    'rfc2833',
    'inband',
    'info',
    'auto'
);


ALTER TYPE public.usersip_dtmfmode OWNER TO postgres;

--
-- Name: usersip_insecure; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_insecure AS ENUM (
    'port',
    'invite',
    'port,invite'
);


ALTER TYPE public.usersip_insecure OWNER TO postgres;

--
-- Name: usersip_nat; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_nat AS ENUM (
    'no',
    'force_rport',
    'comedia',
    'force_rport,comedia',
    'auto_force_rport',
    'auto_comedia',
    'auto_force_rport,auto_comedia'
);


ALTER TYPE public.usersip_nat OWNER TO postgres;

--
-- Name: usersip_progressinband; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_progressinband AS ENUM (
    'no',
    'yes',
    'never'
);


ALTER TYPE public.usersip_progressinband OWNER TO postgres;

--
-- Name: usersip_protocol; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_protocol AS ENUM (
    'sip'
);


ALTER TYPE public.usersip_protocol OWNER TO postgres;

--
-- Name: usersip_session_refresher; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_session_refresher AS ENUM (
    'uac',
    'uas'
);


ALTER TYPE public.usersip_session_refresher OWNER TO postgres;

--
-- Name: usersip_session_timers; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_session_timers AS ENUM (
    'originate',
    'accept',
    'refuse'
);


ALTER TYPE public.usersip_session_timers OWNER TO postgres;

--
-- Name: usersip_videosupport; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.usersip_videosupport AS ENUM (
    'no',
    'yes',
    'always'
);


ALTER TYPE public.usersip_videosupport OWNER TO postgres;

--
-- Name: fill_leaveempty_calls(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: asterisk
--

CREATE FUNCTION public.fill_leaveempty_calls(period_start timestamp with time zone, period_end timestamp with time zone) RETURNS void
    LANGUAGE sql
    AS $_$
INSERT INTO stat_call_on_queue (callid, time, waittime, stat_queue_id, status)
SELECT
  callid,
  enter_time as time,
  EXTRACT(EPOCH FROM (leave_time - enter_time))::INTEGER as waittime,
  stat_queue_id,
  'leaveempty' AS status
FROM (SELECT
        time AS enter_time,
        (select time from queue_log where callid=main.callid AND event='LEAVEEMPTY' LIMIT 1) AS leave_time,
        callid,
        (SELECT id FROM stat_queue WHERE name=queuename) AS stat_queue_id
      FROM queue_log AS main
      WHERE callid IN (SELECT callid FROM queue_log WHERE event = 'LEAVEEMPTY')
            AND event = 'ENTERQUEUE'
            AND time BETWEEN $1 AND $2) AS first;
$_$;


ALTER FUNCTION public.fill_leaveempty_calls(period_start timestamp with time zone, period_end timestamp with time zone) OWNER TO asterisk;

--
-- Name: fill_simple_calls(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: asterisk
--

CREATE FUNCTION public.fill_simple_calls(period_start timestamp with time zone, period_end timestamp with time zone) RETURNS void
    LANGUAGE sql
    AS $_$
  INSERT INTO "stat_call_on_queue" (callid, "time", stat_queue_id, status)
    SELECT
      callid,
      time,
      (SELECT id FROM stat_queue WHERE name=queuename) as stat_queue_id,
      CASE WHEN event = 'FULL' THEN 'full'::call_exit_type
           WHEN event = 'DIVERT_CA_RATIO' THEN 'divert_ca_ratio'
           WHEN event = 'DIVERT_HOLDTIME' THEN 'divert_waittime'
           WHEN event = 'CLOSED' THEN 'closed'
           WHEN event = 'JOINEMPTY' THEN 'joinempty'
      END as status
    FROM queue_log
    WHERE event IN ('FULL', 'DIVERT_CA_RATIO', 'DIVERT_HOLDTIME', 'CLOSED', 'JOINEMPTY') AND
          "time" BETWEEN $1 AND $2;
$_$;


ALTER FUNCTION public.fill_simple_calls(period_start timestamp with time zone, period_end timestamp with time zone) OWNER TO asterisk;

--
-- Name: set_agent_on_pauseall(); Type: FUNCTION; Schema: public; Owner: asterisk
--

CREATE FUNCTION public.set_agent_on_pauseall() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    "number" text;
BEGIN
    SELECT "agent_number" INTO "number" FROM "agent_login_status" WHERE "interface" = NEW."agent";
    IF FOUND THEN
        NEW."agent" := 'Agent/' || "number";
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_agent_on_pauseall() OWNER TO asterisk;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accessfeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accessfeatures (
    id integer NOT NULL,
    host character varying(255) DEFAULT ''::character varying NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    feature character varying(64) DEFAULT 'phonebook'::character varying NOT NULL,
    CONSTRAINT accessfeatures_feature_check CHECK (((feature)::text = 'phonebook'::text))
);


ALTER TABLE public.accessfeatures OWNER TO postgres;

--
-- Name: accessfeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accessfeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accessfeatures_id_seq OWNER TO postgres;

--
-- Name: accessfeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accessfeatures_id_seq OWNED BY public.accessfeatures.id;


--
-- Name: agent_login_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_login_status (
    agent_id integer NOT NULL,
    agent_number character varying(40) NOT NULL,
    extension character varying(80) NOT NULL,
    context character varying(80) NOT NULL,
    interface character varying(128) NOT NULL,
    state_interface character varying(128) NOT NULL,
    paused boolean DEFAULT false NOT NULL,
    paused_reason character varying(80),
    login_at timestamp without time zone DEFAULT timezone('utc'::text, CURRENT_TIMESTAMP) NOT NULL
);


ALTER TABLE public.agent_login_status OWNER TO postgres;

--
-- Name: agent_membership_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_membership_status (
    agent_id integer NOT NULL,
    queue_id integer NOT NULL,
    queue_name character varying(128) NOT NULL,
    penalty integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.agent_membership_status OWNER TO postgres;

--
-- Name: agentfeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agentfeatures (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    firstname character varying(128),
    lastname character varying(128),
    number character varying(40) NOT NULL,
    passwd character varying(128),
    context character varying(39),
    language character varying(20),
    autologoff integer,
    "group" character varying(255),
    description text,
    preprocess_subroutine character varying(40)
);


ALTER TABLE public.agentfeatures OWNER TO postgres;

--
-- Name: agentfeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agentfeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agentfeatures_id_seq OWNER TO postgres;

--
-- Name: agentfeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agentfeatures_id_seq OWNED BY public.agentfeatures.id;


--
-- Name: agentglobalparams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agentglobalparams (
    id integer NOT NULL,
    category character varying(128) NOT NULL,
    option_name character varying(255) NOT NULL,
    option_value character varying(255)
);


ALTER TABLE public.agentglobalparams OWNER TO postgres;

--
-- Name: agentglobalparams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agentglobalparams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.agentglobalparams_id_seq OWNER TO postgres;

--
-- Name: agentglobalparams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agentglobalparams_id_seq OWNED BY public.agentglobalparams.id;


--
-- Name: agentqueueskill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agentqueueskill (
    agentid integer NOT NULL,
    skillid integer NOT NULL,
    weight integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.agentqueueskill OWNER TO postgres;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: application; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application (
    uuid character varying(36) DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128)
);


ALTER TABLE public.application OWNER TO postgres;

--
-- Name: application_dest_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application_dest_node (
    application_uuid character varying(36) NOT NULL,
    type character varying(32) NOT NULL,
    music_on_hold character varying(128),
    answer boolean NOT NULL,
    CONSTRAINT application_dest_node_type_check CHECK (type IN ('holding', 'mixing'))
);


ALTER TABLE public.application_dest_node OWNER TO postgres;

--
-- Name: asterisk_file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asterisk_file (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.asterisk_file OWNER TO postgres;

--
-- Name: asterisk_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asterisk_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.asterisk_file_id_seq OWNER TO postgres;

--
-- Name: asterisk_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asterisk_file_id_seq OWNED BY public.asterisk_file.id;


--
-- Name: asterisk_file_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asterisk_file_section (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    priority integer,
    asterisk_file_id integer NOT NULL
);


ALTER TABLE public.asterisk_file_section OWNER TO postgres;

--
-- Name: asterisk_file_section_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asterisk_file_section_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.asterisk_file_section_id_seq OWNER TO postgres;

--
-- Name: asterisk_file_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asterisk_file_section_id_seq OWNED BY public.asterisk_file_section.id;


--
-- Name: asterisk_file_variable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asterisk_file_variable (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    priority integer,
    asterisk_file_section_id integer NOT NULL
);


ALTER TABLE public.asterisk_file_variable OWNER TO postgres;

--
-- Name: asterisk_file_variable_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asterisk_file_variable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.asterisk_file_variable_id_seq OWNER TO postgres;

--
-- Name: asterisk_file_variable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asterisk_file_variable_id_seq OWNED BY public.asterisk_file_variable.id;


--
-- Name: callerid; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.callerid (
    mode public.callerid_mode,
    callerdisplay character varying(80) DEFAULT ''::character varying NOT NULL,
    type public.callerid_type NOT NULL,
    typeval integer NOT NULL
);


ALTER TABLE public.callerid OWNER TO postgres;

--
-- Name: callfilter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.callfilter (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    type public.callfilter_type NOT NULL,
    bosssecretary public.callfilter_bosssecretary,
    callfrom public.callfilter_callfrom,
    ringseconds integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.callfilter OWNER TO postgres;

--
-- Name: callfilter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.callfilter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.callfilter_id_seq OWNER TO postgres;

--
-- Name: callfilter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.callfilter_id_seq OWNED BY public.callfilter.id;


--
-- Name: callfiltermember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.callfiltermember (
    id integer NOT NULL,
    callfilterid integer DEFAULT 0 NOT NULL,
    type public.callfiltermember_type NOT NULL,
    typeval character varying(128) DEFAULT '0'::character varying NOT NULL,
    ringseconds integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    bstype public.generic_bsfilter NOT NULL,
    active integer DEFAULT 0 NOT NULL,
    CONSTRAINT callfiltermember_bstype_check CHECK ((bstype = ANY (ARRAY['boss'::public.generic_bsfilter, 'secretary'::public.generic_bsfilter])))
);


ALTER TABLE public.callfiltermember OWNER TO postgres;

--
-- Name: callfiltermember_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.callfiltermember_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.callfiltermember_id_seq OWNER TO postgres;

--
-- Name: callfiltermember_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.callfiltermember_id_seq OWNED BY public.callfiltermember.id;


--
-- Name: cel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cel (
    id integer NOT NULL,
    eventtype text NOT NULL,
    eventtime timestamp with time zone NOT NULL,
    userdeftype text NOT NULL,
    cid_name text NOT NULL,
    cid_num text NOT NULL,
    cid_ani text NOT NULL,
    cid_rdnis text NOT NULL,
    cid_dnid text NOT NULL,
    exten text NOT NULL,
    context text NOT NULL,
    channame text NOT NULL,
    appname text NOT NULL,
    appdata text NOT NULL,
    amaflags integer NOT NULL,
    accountcode text NOT NULL,
    peeraccount text NOT NULL,
    uniqueid text NOT NULL,
    linkedid text NOT NULL,
    userfield text NOT NULL,
    peer text NOT NULL,
    extra text,
    call_log_id integer
);


ALTER TABLE public.cel OWNER TO postgres;

--
-- Name: cel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cel_id_seq OWNER TO postgres;

--
-- Name: cel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cel_id_seq OWNED BY public.cel.id;


--
-- Name: conference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conference (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128),
    preprocess_subroutine character varying(39),
    max_users integer DEFAULT 50 NOT NULL,
    record boolean DEFAULT false NOT NULL,
    pin character varying(80),
    quiet_join_leave boolean DEFAULT false NOT NULL,
    announce_join_leave boolean DEFAULT false NOT NULL,
    announce_user_count boolean DEFAULT false NOT NULL,
    announce_only_user boolean DEFAULT true NOT NULL,
    music_on_hold character varying(128),
    admin_pin character varying(80)
);


ALTER TABLE public.conference OWNER TO postgres;

--
-- Name: conference_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conference_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conference_id_seq OWNER TO postgres;

--
-- Name: conference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conference_id_seq OWNED BY public.conference.id;


--
-- Name: context; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.context (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(39) NOT NULL,
    displayname character varying(128),
    contexttype character varying(40) DEFAULT 'internal'::character varying NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.context OWNER TO postgres;

--
-- Name: context_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.context_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.context_id_seq OWNER TO postgres;

--
-- Name: context_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.context_id_seq OWNED BY public.context.id;


--
-- Name: contextinclude; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contextinclude (
    context character varying(39) NOT NULL,
    include character varying(39) NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.contextinclude OWNER TO postgres;

--
-- Name: contextmember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contextmember (
    context character varying(39) NOT NULL,
    type character varying(32) NOT NULL,
    typeval character varying(128) DEFAULT ''::character varying NOT NULL,
    varname character varying(128) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.contextmember OWNER TO postgres;

--
-- Name: contextnumbers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contextnumbers (
    context character varying(39) NOT NULL,
    type public.contextnumbers_type NOT NULL,
    numberbeg character varying(16) DEFAULT ''::character varying NOT NULL,
    numberend character varying(16) DEFAULT ''::character varying NOT NULL,
    didlength integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.contextnumbers OWNER TO postgres;

--
-- Name: contexttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contexttype (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    commented integer,
    deletable integer,
    description text
);


ALTER TABLE public.contexttype OWNER TO postgres;

--
-- Name: contexttype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contexttype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contexttype_id_seq OWNER TO postgres;

--
-- Name: contexttype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contexttype_id_seq OWNED BY public.contexttype.id;


--
-- Name: dhcp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dhcp (
    id integer NOT NULL,
    active integer DEFAULT 0 NOT NULL,
    pool_start character varying(64) DEFAULT ''::character varying NOT NULL,
    pool_end character varying(64) DEFAULT ''::character varying NOT NULL,
    network_interfaces character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.dhcp OWNER TO postgres;

--
-- Name: dhcp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dhcp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dhcp_id_seq OWNER TO postgres;

--
-- Name: dhcp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dhcp_id_seq OWNED BY public.dhcp.id;


--
-- Name: dialaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dialaction (
    event character varying(40) NOT NULL,
    category public.dialaction_category NOT NULL,
    categoryval character varying(128) DEFAULT ''::character varying NOT NULL,
    action public.dialaction_action NOT NULL,
    actionarg1 character varying(255),
    actionarg2 character varying(255)
);


ALTER TABLE public.dialaction OWNER TO postgres;

--
-- Name: dialpattern; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dialpattern (
    id integer NOT NULL,
    type character varying(32) NOT NULL,
    typeid integer NOT NULL,
    externprefix character varying(64),
    prefix character varying(32),
    exten character varying(40) NOT NULL,
    stripnum integer,
    callerid character varying(80)
);


ALTER TABLE public.dialpattern OWNER TO postgres;

--
-- Name: dialpattern_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dialpattern_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dialpattern_id_seq OWNER TO postgres;

--
-- Name: dialpattern_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dialpattern_id_seq OWNED BY public.dialpattern.id;


--
-- Name: endpoint_sip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endpoint_sip (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    label text,
    name text NOT NULL,
    asterisk_id text,
    tenant_uuid character varying(36) NOT NULL,
    transport_uuid uuid,
    template boolean DEFAULT false
);


ALTER TABLE public.endpoint_sip OWNER TO postgres;

--
-- Name: endpoint_sip_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endpoint_sip_section (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type public.endpoint_sip_section_type NOT NULL,
    endpoint_sip_uuid uuid NOT NULL
);


ALTER TABLE public.endpoint_sip_section OWNER TO postgres;

--
-- Name: endpoint_sip_section_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endpoint_sip_section_option (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    endpoint_sip_section_uuid uuid NOT NULL
);


ALTER TABLE public.endpoint_sip_section_option OWNER TO postgres;

--
-- Name: endpoint_sip_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endpoint_sip_template (
    child_uuid uuid NOT NULL,
    parent_uuid uuid NOT NULL,
    priority integer
);


ALTER TABLE public.endpoint_sip_template OWNER TO postgres;

--
-- Name: endpoint_sip_options_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.endpoint_sip_options_view AS
 WITH RECURSIVE anon_1(uuid, level, path, root) AS (
         SELECT endpoint_sip.uuid,
            0 AS level,
            '0'::text AS path,
            endpoint_sip.uuid AS root
           FROM public.endpoint_sip
        UNION ALL
         SELECT endpoint_sip_template.parent_uuid AS uuid,
            (anon_1_1.level + 1) AS level,
            (anon_1_1.path || ((row_number() OVER (PARTITION BY anon_1_1.level ORDER BY endpoint_sip_template.priority))::character varying)::text) AS path,
            anon_1_1.root
           FROM (anon_1 anon_1_1
             JOIN public.endpoint_sip_template ON ((anon_1_1.uuid = endpoint_sip_template.child_uuid)))
        )
 SELECT anon_1.root,
    jsonb_object(array_agg(endpoint_sip_section_option.key ORDER BY anon_1.path DESC), array_agg(endpoint_sip_section_option.value ORDER BY anon_1.path DESC)) AS options
   FROM ((anon_1
     JOIN public.endpoint_sip_section ON ((endpoint_sip_section.endpoint_sip_uuid = anon_1.uuid)))
     JOIN public.endpoint_sip_section_option ON ((endpoint_sip_section_option.endpoint_sip_section_uuid = endpoint_sip_section.uuid)))
  GROUP BY anon_1.root
  WITH NO DATA;


ALTER TABLE public.endpoint_sip_options_view OWNER TO postgres;

--
-- Name: extensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extensions (
    id integer NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    context character varying(39) DEFAULT ''::character varying NOT NULL,
    exten character varying(40) DEFAULT ''::character varying NOT NULL,
    type public.extenumbers_type NOT NULL,
    typeval character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.extensions OWNER TO postgres;

--
-- Name: extensions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.extensions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extensions_id_seq OWNER TO postgres;

--
-- Name: extensions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.extensions_id_seq OWNED BY public.extensions.id;


--
-- Name: external_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_app (
    name text NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    label text,
    configuration json
);


ALTER TABLE public.external_app OWNER TO postgres;

--
-- Name: features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.features (
    id integer NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying(128) NOT NULL,
    category character varying(128) NOT NULL,
    var_name character varying(128) NOT NULL,
    var_val character varying(255)
);


ALTER TABLE public.features OWNER TO postgres;

--
-- Name: features_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.features_id_seq OWNER TO postgres;

--
-- Name: features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.features_id_seq OWNED BY public.features.id;


--
-- Name: func_key; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key (
    id integer NOT NULL,
    type_id integer NOT NULL,
    destination_type_id integer NOT NULL
);


ALTER TABLE public.func_key OWNER TO postgres;

--
-- Name: func_key_dest_agent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_agent (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 11 NOT NULL,
    agent_id integer NOT NULL,
    extension_id integer NOT NULL,
    CONSTRAINT func_key_dest_agent_destination_type_id_check CHECK ((destination_type_id = 11))
);


ALTER TABLE public.func_key_dest_agent OWNER TO postgres;

--
-- Name: func_key_dest_bsfilter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_bsfilter (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 12 NOT NULL,
    filtermember_id integer NOT NULL,
    CONSTRAINT func_key_dest_bsfilter_destination_type_id_check CHECK ((destination_type_id = 12))
);


ALTER TABLE public.func_key_dest_bsfilter OWNER TO postgres;

--
-- Name: func_key_dest_conference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_conference (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 4 NOT NULL,
    conference_id integer NOT NULL,
    CONSTRAINT func_key_dest_conference_destination_type_id_check CHECK ((destination_type_id = 4))
);


ALTER TABLE public.func_key_dest_conference OWNER TO postgres;

--
-- Name: func_key_dest_custom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_custom (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 10 NOT NULL,
    exten character varying(40) NOT NULL,
    CONSTRAINT func_key_dest_custom_destination_type_id_check CHECK ((destination_type_id = 10))
);


ALTER TABLE public.func_key_dest_custom OWNER TO postgres;

--
-- Name: func_key_dest_features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_features (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 8 NOT NULL,
    features_id integer NOT NULL,
    CONSTRAINT func_key_dest_features_destination_type_id_check CHECK ((destination_type_id = 8))
);


ALTER TABLE public.func_key_dest_features OWNER TO postgres;

--
-- Name: func_key_dest_forward; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_forward (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 6 NOT NULL,
    extension_id integer NOT NULL,
    number character varying(40),
    CONSTRAINT func_key_dest_forward_destination_type_id_check CHECK ((destination_type_id = 6))
);


ALTER TABLE public.func_key_dest_forward OWNER TO postgres;

--
-- Name: func_key_dest_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_group (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 2 NOT NULL,
    group_id integer NOT NULL,
    CONSTRAINT func_key_dest_group_destination_type_id_check CHECK ((destination_type_id = 2))
);


ALTER TABLE public.func_key_dest_group OWNER TO postgres;

--
-- Name: func_key_dest_groupmember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_groupmember (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 13 NOT NULL,
    group_id integer NOT NULL,
    extension_id integer NOT NULL,
    CONSTRAINT func_key_dest_groupmember_destination_type_id_check CHECK ((destination_type_id = 13))
);


ALTER TABLE public.func_key_dest_groupmember OWNER TO postgres;

--
-- Name: func_key_dest_paging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_paging (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 9 NOT NULL,
    paging_id integer NOT NULL,
    CONSTRAINT func_key_dest_paging_destination_type_id_check CHECK ((destination_type_id = 9))
);


ALTER TABLE public.func_key_dest_paging OWNER TO postgres;

--
-- Name: func_key_dest_park_position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_park_position (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 7 NOT NULL,
    park_position character varying(40) NOT NULL,
    CONSTRAINT func_key_dest_park_position_destination_type_id_check CHECK ((destination_type_id = 7)),
    CONSTRAINT func_key_dest_park_position_park_position_check CHECK (((park_position)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE public.func_key_dest_park_position OWNER TO postgres;

--
-- Name: func_key_dest_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_queue (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 3 NOT NULL,
    queue_id integer NOT NULL,
    CONSTRAINT func_key_dest_queue_destination_type_id_check CHECK ((destination_type_id = 3))
);


ALTER TABLE public.func_key_dest_queue OWNER TO postgres;

--
-- Name: func_key_dest_service; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_service (
    func_key_id integer NOT NULL,
    destination_type_id integer DEFAULT 5 NOT NULL,
    extension_id integer NOT NULL,
    CONSTRAINT func_key_dest_service_destination_type_id_check CHECK ((destination_type_id = 5))
);


ALTER TABLE public.func_key_dest_service OWNER TO postgres;

--
-- Name: func_key_dest_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_dest_user (
    func_key_id integer NOT NULL,
    user_id integer NOT NULL,
    destination_type_id integer DEFAULT 1 NOT NULL,
    CONSTRAINT func_key_dest_user_destination_type_id_check CHECK ((destination_type_id = 1))
);


ALTER TABLE public.func_key_dest_user OWNER TO postgres;

--
-- Name: func_key_destination_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_destination_type (
    id integer NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.func_key_destination_type OWNER TO postgres;

--
-- Name: func_key_destination_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.func_key_destination_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.func_key_destination_type_id_seq OWNER TO postgres;

--
-- Name: func_key_destination_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.func_key_destination_type_id_seq OWNED BY public.func_key_destination_type.id;


--
-- Name: func_key_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.func_key_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.func_key_id_seq OWNER TO postgres;

--
-- Name: func_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.func_key_id_seq OWNED BY public.func_key.id;


--
-- Name: func_key_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_mapping (
    template_id integer NOT NULL,
    func_key_id integer NOT NULL,
    destination_type_id integer NOT NULL,
    label character varying(128),
    "position" integer NOT NULL,
    blf boolean DEFAULT true NOT NULL,
    CONSTRAINT func_key_mapping_position_check CHECK (("position" > 0))
);


ALTER TABLE public.func_key_mapping OWNER TO postgres;

--
-- Name: func_key_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_template (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128),
    private boolean DEFAULT false NOT NULL
);


ALTER TABLE public.func_key_template OWNER TO postgres;

--
-- Name: func_key_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.func_key_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.func_key_template_id_seq OWNER TO postgres;

--
-- Name: func_key_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.func_key_template_id_seq OWNED BY public.func_key_template.id;


--
-- Name: func_key_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.func_key_type (
    id integer NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.func_key_type OWNER TO postgres;

--
-- Name: func_key_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.func_key_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.func_key_type_id_seq OWNER TO postgres;

--
-- Name: func_key_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.func_key_type_id_seq OWNED BY public.func_key_type.id;


--
-- Name: groupfeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupfeatures (
    id integer NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    label text NOT NULL,
    transfer_user integer DEFAULT 0 NOT NULL,
    transfer_call integer DEFAULT 0 NOT NULL,
    write_caller integer DEFAULT 0 NOT NULL,
    write_calling integer DEFAULT 0 NOT NULL,
    ignore_forward integer DEFAULT 1 NOT NULL,
    timeout integer,
    preprocess_subroutine character varying(39),
    mark_answered_elsewhere integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.groupfeatures OWNER TO postgres;

--
-- Name: groupfeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groupfeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groupfeatures_id_seq OWNER TO postgres;

--
-- Name: groupfeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groupfeatures_id_seq OWNED BY public.groupfeatures.id;


--
-- Name: iaxcallnumberlimits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iaxcallnumberlimits (
    id integer NOT NULL,
    destination character varying(39) NOT NULL,
    netmask character varying(39) NOT NULL,
    calllimits integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.iaxcallnumberlimits OWNER TO postgres;

--
-- Name: iaxcallnumberlimits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.iaxcallnumberlimits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.iaxcallnumberlimits_id_seq OWNER TO postgres;

--
-- Name: iaxcallnumberlimits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.iaxcallnumberlimits_id_seq OWNED BY public.iaxcallnumberlimits.id;


--
-- Name: incall; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incall (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    preprocess_subroutine character varying(39),
    greeting_sound text,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.incall OWNER TO postgres;

--
-- Name: incall_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incall_id_seq OWNER TO postgres;

--
-- Name: incall_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incall_id_seq OWNED BY public.incall.id;


--
-- Name: infos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.infos (
    uuid character varying(38) NOT NULL,
    wazo_version character varying(64) NOT NULL,
    live_reload_enabled boolean DEFAULT true NOT NULL,
    timezone character varying(128),
    configured boolean DEFAULT false NOT NULL
);


ALTER TABLE public.infos OWNER TO postgres;

--
-- Name: ingress_http; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingress_http (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    uri text NOT NULL,
    tenant_uuid character varying(36) NOT NULL
);


ALTER TABLE public.ingress_http OWNER TO postgres;

--
-- Name: ivr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ivr (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    greeting_sound text,
    menu_sound text NOT NULL,
    invalid_sound text,
    abort_sound text,
    timeout integer DEFAULT 5 NOT NULL,
    max_tries integer DEFAULT 3 NOT NULL,
    description text
);


ALTER TABLE public.ivr OWNER TO postgres;

--
-- Name: ivr_choice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ivr_choice (
    id integer NOT NULL,
    ivr_id integer NOT NULL,
    exten character varying(40) NOT NULL
);


ALTER TABLE public.ivr_choice OWNER TO postgres;

--
-- Name: ivr_choice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ivr_choice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ivr_choice_id_seq OWNER TO postgres;

--
-- Name: ivr_choice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ivr_choice_id_seq OWNED BY public.ivr_choice.id;


--
-- Name: ivr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ivr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ivr_id_seq OWNER TO postgres;

--
-- Name: ivr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ivr_id_seq OWNED BY public.ivr.id;


--
-- Name: line_extension; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.line_extension (
    line_id integer NOT NULL,
    extension_id integer NOT NULL,
    main_extension boolean NOT NULL
);


ALTER TABLE public.line_extension OWNER TO postgres;

--
-- Name: linefeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linefeatures (
    id integer NOT NULL,
    device character varying(32),
    configregistrar character varying(128),
    name character varying(128),
    number character varying(40),
    context character varying(39) NOT NULL,
    provisioningid integer NOT NULL,
    num integer DEFAULT 1,
    ipfrom character varying(15),
    application_uuid character varying(36),
    commented integer DEFAULT 0 NOT NULL,
    description text,
    endpoint_sip_uuid uuid,
    endpoint_sccp_id integer,
    endpoint_custom_id integer,
    CONSTRAINT linefeatures_endpoints_check CHECK ((((
CASE
    WHEN (endpoint_sip_uuid IS NULL) THEN 0
    ELSE 1
END +
CASE
    WHEN (endpoint_sccp_id IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN (endpoint_custom_id IS NULL) THEN 0
    ELSE 1
END) <= 1))
);


ALTER TABLE public.linefeatures OWNER TO postgres;

--
-- Name: linefeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.linefeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.linefeatures_id_seq OWNER TO postgres;

--
-- Name: linefeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.linefeatures_id_seq OWNED BY public.linefeatures.id;


--
-- Name: mail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mail (
    id integer NOT NULL,
    mydomain character varying(255) DEFAULT '0'::character varying NOT NULL,
    origin character varying(255) DEFAULT 'xivo-clients.proformatique.com'::character varying NOT NULL,
    relayhost character varying(255),
    fallback_relayhost character varying(255),
    canonical text NOT NULL
);


ALTER TABLE public.mail OWNER TO postgres;

--
-- Name: mail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mail_id_seq OWNER TO postgres;

--
-- Name: mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mail_id_seq OWNED BY public.mail.id;


--
-- Name: meeting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meeting (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    guest_endpoint_sip_uuid uuid,
    tenant_uuid character varying(36) NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
    persistent boolean DEFAULT false NOT NULL,
    number text NOT NULL,
    require_authorization boolean DEFAULT false NOT NULL
);


ALTER TABLE public.meeting OWNER TO postgres;

--
-- Name: meeting_authorization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meeting_authorization (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    guest_uuid uuid NOT NULL,
    meeting_uuid uuid NOT NULL,
    guest_name text,
    status text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);


ALTER TABLE public.meeting_authorization OWNER TO postgres;

--
-- Name: meeting_owner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meeting_owner (
    meeting_uuid uuid NOT NULL,
    user_uuid character varying(38) NOT NULL
);


ALTER TABLE public.meeting_owner OWNER TO postgres;

--
-- Name: moh; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moh (
    uuid character varying(38) NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name text NOT NULL,
    label text NOT NULL,
    mode text NOT NULL,
    application text,
    sort text
);


ALTER TABLE public.moh OWNER TO postgres;

--
-- Name: monitoring; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monitoring (
    id integer NOT NULL,
    maintenance integer DEFAULT 0 NOT NULL,
    alert_emails character varying(4096),
    max_call_duration integer
);


ALTER TABLE public.monitoring OWNER TO postgres;

--
-- Name: monitoring_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.monitoring_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.monitoring_id_seq OWNER TO postgres;

--
-- Name: monitoring_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monitoring_id_seq OWNED BY public.monitoring.id;


--
-- Name: netiface; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.netiface (
    id integer NOT NULL,
    ifname character varying(64) DEFAULT ''::character varying NOT NULL,
    hwtypeid integer DEFAULT 65534 NOT NULL,
    networktype public.netiface_networktype NOT NULL,
    type public.netiface_type NOT NULL,
    family public.netiface_family NOT NULL,
    method public.netiface_method,
    address character varying(39),
    netmask character varying(39),
    broadcast character varying(15),
    gateway character varying(39),
    mtu integer,
    vlanrawdevice character varying(64),
    vlanid integer,
    options text NOT NULL,
    disable integer DEFAULT 0 NOT NULL,
    dcreate integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.netiface OWNER TO postgres;

--
-- Name: netiface_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.netiface_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.netiface_id_seq OWNER TO postgres;

--
-- Name: netiface_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.netiface_id_seq OWNED BY public.netiface.id;


--
-- Name: outcall; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outcall (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    context character varying(39),
    internal integer DEFAULT 0 NOT NULL,
    preprocess_subroutine character varying(39),
    hangupringtime integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.outcall OWNER TO postgres;

--
-- Name: outcall_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.outcall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outcall_id_seq OWNER TO postgres;

--
-- Name: outcall_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.outcall_id_seq OWNED BY public.outcall.id;


--
-- Name: outcalltrunk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outcalltrunk (
    outcallid integer NOT NULL,
    trunkfeaturesid integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.outcalltrunk OWNER TO postgres;

--
-- Name: paging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paging (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    number character varying(32),
    name character varying(128),
    duplex integer DEFAULT 0 NOT NULL,
    ignore integer DEFAULT 0 NOT NULL,
    record integer DEFAULT 0 NOT NULL,
    quiet integer DEFAULT 0 NOT NULL,
    timeout integer DEFAULT 30 NOT NULL,
    announcement_file character varying(64),
    announcement_play integer DEFAULT 0 NOT NULL,
    announcement_caller integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.paging OWNER TO postgres;

--
-- Name: paging_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paging_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paging_id_seq OWNER TO postgres;

--
-- Name: paging_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paging_id_seq OWNED BY public.paging.id;


--
-- Name: paginguser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paginguser (
    pagingid integer NOT NULL,
    userfeaturesid integer NOT NULL,
    caller integer NOT NULL
);


ALTER TABLE public.paginguser OWNER TO postgres;

--
-- Name: parking_lot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parking_lot (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128),
    slots_start character varying(40) NOT NULL,
    slots_end character varying(40) NOT NULL,
    timeout integer,
    music_on_hold character varying(128)
);


ALTER TABLE public.parking_lot OWNER TO postgres;

--
-- Name: parking_lot_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parking_lot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.parking_lot_id_seq OWNER TO postgres;

--
-- Name: parking_lot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parking_lot_id_seq OWNED BY public.parking_lot.id;


--
-- Name: pickup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pickup (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.pickup OWNER TO postgres;

--
-- Name: pickupmember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pickupmember (
    pickupid integer NOT NULL,
    category public.pickup_category NOT NULL,
    membertype public.pickup_membertype NOT NULL,
    memberid integer NOT NULL
);


ALTER TABLE public.pickupmember OWNER TO postgres;

--
-- Name: pjsip_transport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pjsip_transport (
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.pjsip_transport OWNER TO postgres;

--
-- Name: pjsip_transport_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pjsip_transport_option (
    id integer NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    pjsip_transport_uuid uuid NOT NULL
);


ALTER TABLE public.pjsip_transport_option OWNER TO postgres;

--
-- Name: pjsip_transport_option_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pjsip_transport_option_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pjsip_transport_option_id_seq OWNER TO postgres;

--
-- Name: pjsip_transport_option_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pjsip_transport_option_id_seq OWNED BY public.pjsip_transport_option.id;


--
-- Name: provisioning; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provisioning (
    id integer NOT NULL,
    net4_ip character varying(39),
    dhcp_integration integer DEFAULT 0 NOT NULL,
    http_port integer NOT NULL
);


ALTER TABLE public.provisioning OWNER TO postgres;

--
-- Name: provisioning_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.provisioning_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.provisioning_id_seq OWNER TO postgres;

--
-- Name: provisioning_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.provisioning_id_seq OWNED BY public.provisioning.id;


--
-- Name: queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queue (
    name character varying(128) NOT NULL,
    musicclass character varying(128),
    announce character varying(128),
    context character varying(39),
    timeout integer DEFAULT 0,
    "monitor-type" public.queue_monitor_type,
    "monitor-format" character varying(128),
    "queue-youarenext" character varying(128),
    "queue-thereare" character varying(128),
    "queue-callswaiting" character varying(128),
    "queue-holdtime" character varying(128),
    "queue-minutes" character varying(128),
    "queue-seconds" character varying(128),
    "queue-thankyou" character varying(128),
    "queue-reporthold" character varying(128),
    "periodic-announce" text,
    "announce-frequency" integer,
    "periodic-announce-frequency" integer,
    "announce-round-seconds" integer,
    "announce-holdtime" character varying(4),
    retry integer,
    wrapuptime integer,
    maxlen integer,
    servicelevel integer,
    strategy character varying(11),
    joinempty character varying(255),
    leavewhenempty character varying(255),
    ringinuse integer DEFAULT 0 NOT NULL,
    reportholdtime integer DEFAULT 0 NOT NULL,
    memberdelay integer,
    weight integer,
    timeoutrestart integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    category public.queue_category NOT NULL,
    timeoutpriority character varying(10) DEFAULT 'app'::character varying NOT NULL,
    autofill integer DEFAULT 1 NOT NULL,
    autopause character varying(3) DEFAULT 'no'::character varying NOT NULL,
    setinterfacevar integer DEFAULT 0 NOT NULL,
    setqueueentryvar integer DEFAULT 0 NOT NULL,
    setqueuevar integer DEFAULT 0 NOT NULL,
    membermacro character varying(1024),
    "min-announce-frequency" integer DEFAULT 60 NOT NULL,
    "random-periodic-announce" integer DEFAULT 0 NOT NULL,
    "announce-position" character varying(1024) DEFAULT 'yes'::character varying NOT NULL,
    "announce-position-limit" integer DEFAULT 5 NOT NULL,
    defaultrule character varying(1024),
    CONSTRAINT queue_autopause_check CHECK (autopause IN ('no', 'yes', 'all'))
);


ALTER TABLE public.queue OWNER TO postgres;

--
-- Name: queue_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queue_log (
    "time" timestamp with time zone,
    callid character varying(80),
    queuename character varying(256),
    agent text,
    event character varying(20),
    data1 text,
    data2 text,
    data3 text,
    data4 text,
    data5 text,
    id integer NOT NULL
);


ALTER TABLE public.queue_log OWNER TO postgres;

--
-- Name: queue_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queue_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queue_log_id_seq OWNER TO postgres;

--
-- Name: queue_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queue_log_id_seq OWNED BY public.queue_log.id;


--
-- Name: queuefeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queuefeatures (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    displayname character varying(128) NOT NULL,
    number character varying(40),
    context character varying(39),
    data_quality integer DEFAULT 0 NOT NULL,
    hitting_callee integer DEFAULT 0 NOT NULL,
    hitting_caller integer DEFAULT 0 NOT NULL,
    retries integer DEFAULT 0 NOT NULL,
    ring integer DEFAULT 0 NOT NULL,
    transfer_user integer DEFAULT 0 NOT NULL,
    transfer_call integer DEFAULT 0 NOT NULL,
    write_caller integer DEFAULT 0 NOT NULL,
    write_calling integer DEFAULT 0 NOT NULL,
    ignore_forward integer DEFAULT 1 NOT NULL,
    url character varying(255) DEFAULT ''::character varying NOT NULL,
    announceoverride character varying(128) DEFAULT ''::character varying NOT NULL,
    timeout integer,
    preprocess_subroutine character varying(39),
    announce_holdtime integer DEFAULT 0 NOT NULL,
    waittime integer,
    waitratio double precision,
    mark_answered_elsewhere integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.queuefeatures OWNER TO postgres;

--
-- Name: queuefeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queuefeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queuefeatures_id_seq OWNER TO postgres;

--
-- Name: queuefeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queuefeatures_id_seq OWNED BY public.queuefeatures.id;


--
-- Name: queuemember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queuemember (
    queue_name character varying(128) NOT NULL,
    interface character varying(128) NOT NULL,
    penalty integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    usertype public.queuemember_usertype NOT NULL,
    userid integer NOT NULL,
    channel character varying(25) NOT NULL,
    category public.queue_category NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.queuemember OWNER TO postgres;

--
-- Name: queuepenalty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queuepenalty (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.queuepenalty OWNER TO postgres;

--
-- Name: queuepenalty_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queuepenalty_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queuepenalty_id_seq OWNER TO postgres;

--
-- Name: queuepenalty_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queuepenalty_id_seq OWNED BY public.queuepenalty.id;


--
-- Name: queuepenaltychange; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queuepenaltychange (
    queuepenalty_id integer NOT NULL,
    seconds integer DEFAULT 0 NOT NULL,
    maxp_sign public.queuepenaltychange_sign,
    maxp_value integer,
    minp_sign public.queuepenaltychange_sign,
    minp_value integer
);


ALTER TABLE public.queuepenaltychange OWNER TO postgres;

--
-- Name: queueskill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queueskill (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    catid integer,
    name character varying(64) DEFAULT ''::character varying NOT NULL,
    description text
);


ALTER TABLE public.queueskill OWNER TO postgres;

--
-- Name: queueskill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queueskill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queueskill_id_seq OWNER TO postgres;

--
-- Name: queueskill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queueskill_id_seq OWNED BY public.queueskill.id;


--
-- Name: queueskillcat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queueskillcat (
    id integer NOT NULL,
    name character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.queueskillcat OWNER TO postgres;

--
-- Name: queueskillcat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queueskillcat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queueskillcat_id_seq OWNER TO postgres;

--
-- Name: queueskillcat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queueskillcat_id_seq OWNED BY public.queueskillcat.id;


--
-- Name: queueskillrule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.queueskillrule (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(64) NOT NULL,
    rule text
);


ALTER TABLE public.queueskillrule OWNER TO postgres;

--
-- Name: queueskillrule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.queueskillrule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queueskillrule_id_seq OWNER TO postgres;

--
-- Name: queueskillrule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.queueskillrule_id_seq OWNED BY public.queueskillrule.id;


--
-- Name: resolvconf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resolvconf (
    id integer NOT NULL,
    hostname character varying(63) DEFAULT 'xivo'::character varying NOT NULL,
    domain character varying(255) DEFAULT ''::character varying NOT NULL,
    nameserver1 character varying(255),
    nameserver2 character varying(255),
    nameserver3 character varying(255),
    search character varying(255),
    description text
);


ALTER TABLE public.resolvconf OWNER TO postgres;

--
-- Name: resolvconf_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resolvconf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resolvconf_id_seq OWNER TO postgres;

--
-- Name: resolvconf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resolvconf_id_seq OWNED BY public.resolvconf.id;


--
-- Name: rightcall; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rightcall (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) DEFAULT ''::character varying NOT NULL,
    passwd character varying(40) DEFAULT ''::character varying NOT NULL,
    "authorization" integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.rightcall OWNER TO postgres;

--
-- Name: rightcall_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rightcall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rightcall_id_seq OWNER TO postgres;

--
-- Name: rightcall_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rightcall_id_seq OWNED BY public.rightcall.id;


--
-- Name: rightcallexten; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rightcallexten (
    id integer NOT NULL,
    rightcallid integer DEFAULT 0 NOT NULL,
    exten character varying(40) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.rightcallexten OWNER TO postgres;

--
-- Name: rightcallexten_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rightcallexten_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rightcallexten_id_seq OWNER TO postgres;

--
-- Name: rightcallexten_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rightcallexten_id_seq OWNED BY public.rightcallexten.id;


--
-- Name: rightcallmember; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rightcallmember (
    id integer NOT NULL,
    rightcallid integer DEFAULT 0 NOT NULL,
    type character varying(64) NOT NULL,
    typeval character varying(128) DEFAULT '0'::character varying NOT NULL,
    CONSTRAINT rightcallmember_type_check CHECK (type IN ('group', 'outcall', 'user'))
);


ALTER TABLE public.rightcallmember OWNER TO postgres;

--
-- Name: rightcallmember_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rightcallmember_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rightcallmember_id_seq OWNER TO postgres;

--
-- Name: rightcallmember_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rightcallmember_id_seq OWNED BY public.rightcallmember.id;


--
-- Name: sccpdevice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sccpdevice (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    device character varying(80) NOT NULL,
    line character varying(80) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.sccpdevice OWNER TO postgres;

--
-- Name: sccpdevice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sccpdevice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sccpdevice_id_seq OWNER TO postgres;

--
-- Name: sccpdevice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sccpdevice_id_seq OWNED BY public.sccpdevice.id;


--
-- Name: sccpgeneralsettings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sccpgeneralsettings (
    id integer NOT NULL,
    option_name character varying(80) NOT NULL,
    option_value character varying(80) NOT NULL
);


ALTER TABLE public.sccpgeneralsettings OWNER TO postgres;

--
-- Name: sccpgeneralsettings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sccpgeneralsettings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sccpgeneralsettings_id_seq OWNER TO postgres;

--
-- Name: sccpgeneralsettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sccpgeneralsettings_id_seq OWNED BY public.sccpgeneralsettings.id;


--
-- Name: sccpline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sccpline (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(80) NOT NULL,
    context character varying(80) NOT NULL,
    cid_name character varying(80) NOT NULL,
    cid_num character varying(80) NOT NULL,
    disallow character varying(100),
    allow text,
    protocol public.trunk_protocol DEFAULT 'sccp'::public.trunk_protocol NOT NULL,
    commented integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.sccpline OWNER TO postgres;

--
-- Name: sccpline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sccpline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sccpline_id_seq OWNER TO postgres;

--
-- Name: sccpline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sccpline_id_seq OWNED BY public.sccpline.id;


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedule (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(255),
    timezone character varying(128),
    fallback_action public.dialaction_action DEFAULT 'none'::public.dialaction_action NOT NULL,
    fallback_actionid character varying(255),
    fallback_actionargs character varying(255),
    description text,
    commented integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.schedule OWNER TO postgres;

--
-- Name: schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedule_id_seq OWNER TO postgres;

--
-- Name: schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedule_id_seq OWNED BY public.schedule.id;


--
-- Name: schedule_path; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedule_path (
    schedule_id integer NOT NULL,
    path public.schedule_path_type NOT NULL,
    pathid integer NOT NULL
);


ALTER TABLE public.schedule_path OWNER TO postgres;

--
-- Name: schedule_time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedule_time (
    id integer NOT NULL,
    schedule_id integer,
    mode public.schedule_time_mode DEFAULT 'opened'::public.schedule_time_mode NOT NULL,
    hours character varying(512),
    weekdays character varying(512),
    monthdays character varying(512),
    months character varying(512),
    action public.dialaction_action,
    actionid character varying(255),
    actionargs character varying(255),
    commented integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.schedule_time OWNER TO postgres;

--
-- Name: schedule_time_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedule_time_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedule_time_id_seq OWNER TO postgres;

--
-- Name: schedule_time_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedule_time_id_seq OWNED BY public.schedule_time.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sessid character varying(32) NOT NULL,
    start integer NOT NULL,
    expire integer NOT NULL,
    identifier character varying(255) NOT NULL,
    data text NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: stat_agent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_agent (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    agent_id integer,
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.stat_agent OWNER TO postgres;

--
-- Name: stat_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_agent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_agent_id_seq OWNER TO postgres;

--
-- Name: stat_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_agent_id_seq OWNED BY public.stat_agent.id;


--
-- Name: stat_agent_periodic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_agent_periodic (
    id integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    login_time interval DEFAULT '00:00:00'::interval NOT NULL,
    pause_time interval DEFAULT '00:00:00'::interval NOT NULL,
    wrapup_time interval DEFAULT '00:00:00'::interval NOT NULL,
    stat_agent_id integer
);


ALTER TABLE public.stat_agent_periodic OWNER TO postgres;

--
-- Name: stat_agent_periodic_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_agent_periodic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_agent_periodic_id_seq OWNER TO postgres;

--
-- Name: stat_agent_periodic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_agent_periodic_id_seq OWNED BY public.stat_agent_periodic.id;


--
-- Name: stat_call_on_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_call_on_queue (
    id integer NOT NULL,
    callid character varying(32) NOT NULL,
    "time" timestamp with time zone NOT NULL,
    ringtime integer DEFAULT 0 NOT NULL,
    talktime integer DEFAULT 0 NOT NULL,
    waittime integer DEFAULT 0 NOT NULL,
    status public.call_exit_type NOT NULL,
    stat_queue_id integer,
    stat_agent_id integer
);


ALTER TABLE public.stat_call_on_queue OWNER TO postgres;

--
-- Name: stat_call_on_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_call_on_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_call_on_queue_id_seq OWNER TO postgres;

--
-- Name: stat_call_on_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_call_on_queue_id_seq OWNED BY public.stat_call_on_queue.id;


--
-- Name: stat_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_queue (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    queue_id integer,
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.stat_queue OWNER TO postgres;

--
-- Name: stat_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_queue_id_seq OWNER TO postgres;

--
-- Name: stat_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_queue_id_seq OWNED BY public.stat_queue.id;


--
-- Name: stat_queue_periodic; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_queue_periodic (
    id integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    answered integer DEFAULT 0 NOT NULL,
    abandoned integer DEFAULT 0 NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    "full" integer DEFAULT 0 NOT NULL,
    closed integer DEFAULT 0 NOT NULL,
    joinempty integer DEFAULT 0 NOT NULL,
    leaveempty integer DEFAULT 0 NOT NULL,
    divert_ca_ratio integer DEFAULT 0 NOT NULL,
    divert_waittime integer DEFAULT 0 NOT NULL,
    timeout integer DEFAULT 0 NOT NULL,
    stat_queue_id integer
);


ALTER TABLE public.stat_queue_periodic OWNER TO postgres;

--
-- Name: stat_queue_periodic_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_queue_periodic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_queue_periodic_id_seq OWNER TO postgres;

--
-- Name: stat_queue_periodic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_queue_periodic_id_seq OWNED BY public.stat_queue_periodic.id;


--
-- Name: stat_switchboard_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stat_switchboard_queue (
    id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    end_type public.stat_switchboard_endtype NOT NULL,
    wait_time double precision NOT NULL,
    queue_id integer NOT NULL
);


ALTER TABLE public.stat_switchboard_queue OWNER TO postgres;

--
-- Name: stat_switchboard_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stat_switchboard_queue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_switchboard_queue_id_seq OWNER TO postgres;

--
-- Name: stat_switchboard_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stat_switchboard_queue_id_seq OWNED BY public.stat_switchboard_queue.id;


--
-- Name: staticiax; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staticiax (
    id integer NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying(128) NOT NULL,
    category character varying(128) NOT NULL,
    var_name character varying(128) NOT NULL,
    var_val character varying(255)
);


ALTER TABLE public.staticiax OWNER TO postgres;

--
-- Name: staticiax_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staticiax_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staticiax_id_seq OWNER TO postgres;

--
-- Name: staticiax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staticiax_id_seq OWNED BY public.staticiax.id;


--
-- Name: staticqueue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staticqueue (
    id integer NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying(128) NOT NULL,
    category character varying(128) NOT NULL,
    var_name character varying(128) NOT NULL,
    var_val character varying(128)
);


ALTER TABLE public.staticqueue OWNER TO postgres;

--
-- Name: staticqueue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staticqueue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staticqueue_id_seq OWNER TO postgres;

--
-- Name: staticqueue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staticqueue_id_seq OWNED BY public.staticqueue.id;


--
-- Name: staticvoicemail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staticvoicemail (
    id integer NOT NULL,
    cat_metric integer DEFAULT 0 NOT NULL,
    var_metric integer DEFAULT 0 NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    filename character varying(128) NOT NULL,
    category character varying(128) NOT NULL,
    var_name character varying(128) NOT NULL,
    var_val text
);


ALTER TABLE public.staticvoicemail OWNER TO postgres;

--
-- Name: staticvoicemail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staticvoicemail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staticvoicemail_id_seq OWNER TO postgres;

--
-- Name: staticvoicemail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staticvoicemail_id_seq OWNED BY public.staticvoicemail.id;


--
-- Name: stats_conf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_conf (
    id integer NOT NULL,
    name character varying(64) DEFAULT ''::character varying NOT NULL,
    hour_start time without time zone NOT NULL,
    hour_end time without time zone NOT NULL,
    homepage integer,
    timezone character varying(128) DEFAULT ''::character varying NOT NULL,
    default_delta character varying(16) DEFAULT '0'::character varying NOT NULL,
    monday smallint DEFAULT 0 NOT NULL,
    tuesday smallint DEFAULT 0 NOT NULL,
    wednesday smallint DEFAULT 0 NOT NULL,
    thursday smallint DEFAULT 0 NOT NULL,
    friday smallint DEFAULT 0 NOT NULL,
    saturday smallint DEFAULT 0 NOT NULL,
    sunday smallint DEFAULT 0 NOT NULL,
    period1 character varying(16) DEFAULT '0'::character varying NOT NULL,
    period2 character varying(16) DEFAULT '0'::character varying NOT NULL,
    period3 character varying(16) DEFAULT '0'::character varying NOT NULL,
    period4 character varying(16) DEFAULT '0'::character varying NOT NULL,
    period5 character varying(16) DEFAULT '0'::character varying NOT NULL,
    dbegcache integer DEFAULT 0,
    dendcache integer DEFAULT 0,
    dgenercache integer DEFAULT 0,
    dcreate integer DEFAULT 0,
    dupdate integer DEFAULT 0,
    disable smallint DEFAULT 0 NOT NULL,
    description text
);


ALTER TABLE public.stats_conf OWNER TO postgres;

--
-- Name: stats_conf_agent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_conf_agent (
    stats_conf_id integer NOT NULL,
    agentfeatures_id integer NOT NULL
);


ALTER TABLE public.stats_conf_agent OWNER TO postgres;

--
-- Name: stats_conf_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stats_conf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stats_conf_id_seq OWNER TO postgres;

--
-- Name: stats_conf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stats_conf_id_seq OWNED BY public.stats_conf.id;


--
-- Name: stats_conf_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_conf_queue (
    stats_conf_id integer NOT NULL,
    queuefeatures_id integer NOT NULL,
    qos smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.stats_conf_queue OWNER TO postgres;

--
-- Name: stats_conf_xivouser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_conf_xivouser (
    stats_conf_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.stats_conf_xivouser OWNER TO postgres;

--
-- Name: switchboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.switchboard (
    uuid character varying(38) NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    hold_moh_uuid character varying(38),
    queue_moh_uuid character varying(38),
    timeout integer
);


ALTER TABLE public.switchboard OWNER TO postgres;

--
-- Name: switchboard_member_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.switchboard_member_user (
    switchboard_uuid character varying(38) NOT NULL,
    user_uuid character varying(38) NOT NULL
);


ALTER TABLE public.switchboard_member_user OWNER TO postgres;

--
-- Name: tenant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant (
    uuid character varying(36) DEFAULT public.uuid_generate_v4() NOT NULL,
    slug character varying(10),
    sip_templates_generated boolean DEFAULT false NOT NULL,
    global_sip_template_uuid uuid,
    webrtc_sip_template_uuid uuid,
    registration_trunk_sip_template_uuid uuid,
    meeting_guest_sip_template_uuid uuid,
    twilio_trunk_sip_template_uuid uuid
);


ALTER TABLE public.tenant OWNER TO postgres;

--
-- Name: trunkfeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trunkfeatures (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    endpoint_sip_uuid uuid,
    endpoint_iax_id integer,
    endpoint_custom_id integer,
    register_iax_id integer,
    registercommented integer DEFAULT 0 NOT NULL,
    description text,
    context character varying(39),
    twilio_incoming boolean DEFAULT false NOT NULL,
    CONSTRAINT trunkfeatures_endpoint_register_check CHECK (((register_iax_id IS NULL) OR ((register_iax_id IS NOT NULL) AND (endpoint_sip_uuid IS NULL) AND (endpoint_custom_id IS NULL)))),
    CONSTRAINT trunkfeatures_endpoints_check CHECK ((((
CASE
    WHEN (endpoint_sip_uuid IS NULL) THEN 0
    ELSE 1
END +
CASE
    WHEN (endpoint_iax_id IS NULL) THEN 0
    ELSE 1
END) +
CASE
    WHEN (endpoint_custom_id IS NULL) THEN 0
    ELSE 1
END) <= 1))
);


ALTER TABLE public.trunkfeatures OWNER TO postgres;

--
-- Name: trunkfeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trunkfeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trunkfeatures_id_seq OWNER TO postgres;

--
-- Name: trunkfeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trunkfeatures_id_seq OWNED BY public.trunkfeatures.id;


--
-- Name: user_external_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_external_app (
    name text NOT NULL,
    user_uuid character varying(38) NOT NULL,
    label text,
    configuration json
);


ALTER TABLE public.user_external_app OWNER TO postgres;

--
-- Name: user_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_line (
    user_id integer NOT NULL,
    line_id integer NOT NULL,
    main_user boolean NOT NULL,
    main_line boolean NOT NULL
);


ALTER TABLE public.user_line OWNER TO postgres;

--
-- Name: usercustom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usercustom (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(40),
    context character varying(39),
    interface character varying(128) NOT NULL,
    intfsuffix character varying(32) DEFAULT ''::character varying NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    protocol public.trunk_protocol DEFAULT 'custom'::public.trunk_protocol NOT NULL,
    category public.usercustom_category NOT NULL
);


ALTER TABLE public.usercustom OWNER TO postgres;

--
-- Name: usercustom_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usercustom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usercustom_id_seq OWNER TO postgres;

--
-- Name: usercustom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usercustom_id_seq OWNED BY public.usercustom.id;


--
-- Name: userfeatures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.userfeatures (
    id integer NOT NULL,
    uuid character varying(38) NOT NULL,
    firstname character varying(128) DEFAULT ''::character varying NOT NULL,
    email character varying(254),
    voicemailid integer,
    agentid integer,
    pictureid integer,
    tenant_uuid character varying(36) NOT NULL,
    callerid character varying(160),
    ringseconds integer DEFAULT 30 NOT NULL,
    simultcalls integer DEFAULT 5 NOT NULL,
    enableclient integer DEFAULT 0 NOT NULL,
    loginclient character varying(254) DEFAULT ''::character varying NOT NULL,
    passwdclient character varying(64) DEFAULT ''::character varying NOT NULL,
    enablehint integer DEFAULT 1 NOT NULL,
    enablevoicemail integer DEFAULT 0 NOT NULL,
    enablexfer integer DEFAULT 0 NOT NULL,
    dtmf_hangup integer DEFAULT 0 NOT NULL,
    enableonlinerec integer DEFAULT 0 NOT NULL,
    call_record_outgoing_external_enabled boolean DEFAULT false NOT NULL,
    call_record_outgoing_internal_enabled boolean DEFAULT false NOT NULL,
    call_record_incoming_external_enabled boolean DEFAULT false NOT NULL,
    call_record_incoming_internal_enabled boolean DEFAULT false NOT NULL,
    incallfilter integer DEFAULT 0 NOT NULL,
    enablednd integer DEFAULT 0 NOT NULL,
    enableunc integer DEFAULT 0 NOT NULL,
    destunc character varying(128) DEFAULT ''::character varying NOT NULL,
    enablerna integer DEFAULT 0 NOT NULL,
    destrna character varying(128) DEFAULT ''::character varying NOT NULL,
    enablebusy integer DEFAULT 0 NOT NULL,
    destbusy character varying(128) DEFAULT ''::character varying NOT NULL,
    musiconhold character varying(128) DEFAULT ''::character varying NOT NULL,
    outcallerid character varying(80) DEFAULT ''::character varying NOT NULL,
    mobilephonenumber character varying(128) DEFAULT ''::character varying NOT NULL,
    bsfilter public.generic_bsfilter DEFAULT 'no'::public.generic_bsfilter NOT NULL,
    preprocess_subroutine character varying(39),
    timezone character varying(128),
    language character varying(20),
    ringintern character varying(64),
    ringextern character varying(64),
    ringgroup character varying(64),
    ringforward character varying(64),
    rightcallcode character varying(16),
    commented integer DEFAULT 0 NOT NULL,
    func_key_template_id integer,
    func_key_private_template_id integer NOT NULL,
    subscription_type integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    lastname character varying(128) DEFAULT ''::character varying NOT NULL,
    userfield character varying(128) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.userfeatures OWNER TO postgres;

--
-- Name: userfeatures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.userfeatures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.userfeatures_id_seq OWNER TO postgres;

--
-- Name: userfeatures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.userfeatures_id_seq OWNED BY public.userfeatures.id;


--
-- Name: useriax; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.useriax (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(40) NOT NULL,
    type public.useriax_type NOT NULL,
    username character varying(80),
    secret character varying(80) DEFAULT ''::character varying NOT NULL,
    dbsecret character varying(255) DEFAULT ''::character varying NOT NULL,
    context character varying(39),
    language character varying(20),
    accountcode character varying(20),
    amaflags public.useriax_amaflags DEFAULT 'default'::public.useriax_amaflags,
    mailbox character varying(80),
    callerid character varying(160),
    fullname character varying(80),
    cid_number character varying(80),
    trunk integer DEFAULT 0 NOT NULL,
    auth public.useriax_auth DEFAULT 'plaintext,md5'::public.useriax_auth NOT NULL,
    encryption public.useriax_encryption,
    forceencryption public.useriax_encryption,
    maxauthreq integer,
    inkeys character varying(80),
    outkey character varying(80),
    adsi integer,
    transfer public.useriax_transfer,
    codecpriority public.useriax_codecpriority,
    jitterbuffer integer,
    forcejitterbuffer integer,
    sendani integer DEFAULT 0 NOT NULL,
    qualify character varying(4) DEFAULT 'no'::character varying NOT NULL,
    qualifysmoothing integer DEFAULT 0 NOT NULL,
    qualifyfreqok integer DEFAULT 60000 NOT NULL,
    qualifyfreqnotok integer DEFAULT 10000 NOT NULL,
    timezone character varying(80),
    disallow character varying(100),
    allow text,
    mohinterpret character varying(80),
    mohsuggest character varying(80),
    deny character varying(31),
    permit character varying(31),
    defaultip character varying(255),
    sourceaddress character varying(255),
    setvar character varying(100) DEFAULT ''::character varying NOT NULL,
    host character varying(255) DEFAULT 'dynamic'::character varying NOT NULL,
    port integer,
    mask character varying(15),
    regexten character varying(80),
    peercontext character varying(80),
    immediate integer,
    keyrotate integer,
    parkinglot integer,
    protocol public.trunk_protocol DEFAULT 'iax'::public.trunk_protocol NOT NULL,
    category public.useriax_category NOT NULL,
    commented integer DEFAULT 0 NOT NULL,
    requirecalltoken character varying(4) DEFAULT 'no'::character varying NOT NULL,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


ALTER TABLE public.useriax OWNER TO postgres;

--
-- Name: useriax_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.useriax_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.useriax_id_seq OWNER TO postgres;

--
-- Name: useriax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.useriax_id_seq OWNED BY public.useriax.id;


--
-- Name: usersip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usersip (
    id integer NOT NULL,
    tenant_uuid character varying(36) NOT NULL,
    name character varying(40) NOT NULL,
    type public.useriax_type NOT NULL,
    username character varying(80),
    secret character varying(80) DEFAULT ''::character varying NOT NULL,
    md5secret character varying(32) DEFAULT ''::character varying NOT NULL,
    context character varying(39),
    language character varying(20),
    accountcode character varying(20),
    amaflags public.useriax_amaflags DEFAULT 'default'::public.useriax_amaflags NOT NULL,
    allowtransfer integer,
    fromuser character varying(80),
    fromdomain character varying(255),
    subscribemwi integer DEFAULT 0 NOT NULL,
    buggymwi integer,
    "call-limit" integer DEFAULT 10 NOT NULL,
    callerid character varying(160),
    fullname character varying(80),
    cid_number character varying(80),
    maxcallbitrate integer,
    insecure public.usersip_insecure,
    nat public.usersip_nat,
    promiscredir integer,
    usereqphone integer,
    videosupport public.usersip_videosupport,
    trustrpid integer,
    sendrpid character varying(16),
    allowsubscribe integer,
    allowoverlap integer,
    dtmfmode public.usersip_dtmfmode,
    rfc2833compensate integer,
    qualify character varying(4),
    g726nonstandard integer,
    disallow character varying(100),
    allow text,
    autoframing integer,
    mohinterpret character varying(80),
    useclientcode integer,
    progressinband public.usersip_progressinband,
    t38pt_udptl integer,
    t38pt_usertpsource integer,
    rtptimeout integer,
    rtpholdtimeout integer,
    rtpkeepalive integer,
    deny character varying(31),
    permit character varying(31),
    defaultip character varying(255),
    host character varying(255) DEFAULT 'dynamic'::character varying NOT NULL,
    port integer,
    regexten character varying(80),
    subscribecontext character varying(80),
    vmexten character varying(40),
    callingpres integer,
    parkinglot integer,
    protocol public.trunk_protocol DEFAULT 'sip'::public.trunk_protocol NOT NULL,
    category public.useriax_category NOT NULL,
    outboundproxy character varying(1024),
    transport character varying(255),
    remotesecret character varying(255),
    directmedia character varying(20),
    callcounter integer,
    busylevel integer,
    ignoresdpversion integer,
    "session-timers" public.usersip_session_timers,
    "session-expires" integer,
    "session-minse" integer,
    "session-refresher" public.usersip_session_refresher,
    callbackextension character varying(255),
    timert1 integer,
    timerb integer,
    qualifyfreq integer,
    contactpermit character varying(1024),
    contactdeny character varying(1024),
    unsolicited_mailbox character varying(1024),
    use_q850_reason integer,
    encryption integer,
    snom_aoc_enabled integer,
    maxforwards integer,
    disallowed_methods character varying(1024),
    textsupport integer,
    commented integer DEFAULT 0 NOT NULL,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    CONSTRAINT usersip_directmedia_check CHECK (((directmedia)::text = ANY ((ARRAY['no'::character varying, 'yes'::character varying, 'nonat'::character varying, 'update'::character varying, 'update,nonat'::character varying, 'outgoing'::character varying])::text[])))
);


ALTER TABLE public.usersip OWNER TO postgres;

--
-- Name: usersip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usersip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usersip_id_seq OWNER TO postgres;

--
-- Name: usersip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usersip_id_seq OWNED BY public.usersip.id;


--
-- Name: voicemail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voicemail (
    uniqueid integer NOT NULL,
    context character varying(39) NOT NULL,
    mailbox character varying(40) NOT NULL,
    password character varying(80),
    fullname character varying(80) DEFAULT ''::character varying NOT NULL,
    email character varying(80),
    pager character varying(80),
    language character varying(20),
    tz character varying(80),
    attach integer,
    deletevoicemail integer DEFAULT 0 NOT NULL,
    maxmsg integer,
    skipcheckpass integer DEFAULT 0 NOT NULL,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    commented integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.voicemail OWNER TO postgres;

--
-- Name: voicemail_uniqueid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voicemail_uniqueid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voicemail_uniqueid_seq OWNER TO postgres;

--
-- Name: voicemail_uniqueid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voicemail_uniqueid_seq OWNED BY public.voicemail.uniqueid;


--
-- Name: accessfeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accessfeatures ALTER COLUMN id SET DEFAULT nextval('public.accessfeatures_id_seq'::regclass);


--
-- Name: agentfeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentfeatures ALTER COLUMN id SET DEFAULT nextval('public.agentfeatures_id_seq'::regclass);


--
-- Name: agentglobalparams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentglobalparams ALTER COLUMN id SET DEFAULT nextval('public.agentglobalparams_id_seq'::regclass);


--
-- Name: asterisk_file id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file ALTER COLUMN id SET DEFAULT nextval('public.asterisk_file_id_seq'::regclass);


--
-- Name: asterisk_file_section id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_section ALTER COLUMN id SET DEFAULT nextval('public.asterisk_file_section_id_seq'::regclass);


--
-- Name: asterisk_file_variable id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_variable ALTER COLUMN id SET DEFAULT nextval('public.asterisk_file_variable_id_seq'::regclass);


--
-- Name: callfilter id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfilter ALTER COLUMN id SET DEFAULT nextval('public.callfilter_id_seq'::regclass);


--
-- Name: callfiltermember id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfiltermember ALTER COLUMN id SET DEFAULT nextval('public.callfiltermember_id_seq'::regclass);


--
-- Name: cel id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cel ALTER COLUMN id SET DEFAULT nextval('public.cel_id_seq'::regclass);


--
-- Name: conference id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conference ALTER COLUMN id SET DEFAULT nextval('public.conference_id_seq'::regclass);


--
-- Name: context id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context ALTER COLUMN id SET DEFAULT nextval('public.context_id_seq'::regclass);


--
-- Name: contexttype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contexttype ALTER COLUMN id SET DEFAULT nextval('public.contexttype_id_seq'::regclass);


--
-- Name: dhcp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dhcp ALTER COLUMN id SET DEFAULT nextval('public.dhcp_id_seq'::regclass);


--
-- Name: dialpattern id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dialpattern ALTER COLUMN id SET DEFAULT nextval('public.dialpattern_id_seq'::regclass);


--
-- Name: extensions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extensions ALTER COLUMN id SET DEFAULT nextval('public.extensions_id_seq'::regclass);


--
-- Name: features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.features ALTER COLUMN id SET DEFAULT nextval('public.features_id_seq'::regclass);


--
-- Name: func_key id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key ALTER COLUMN id SET DEFAULT nextval('public.func_key_id_seq'::regclass);


--
-- Name: func_key_destination_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_destination_type ALTER COLUMN id SET DEFAULT nextval('public.func_key_destination_type_id_seq'::regclass);


--
-- Name: func_key_template id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_template ALTER COLUMN id SET DEFAULT nextval('public.func_key_template_id_seq'::regclass);


--
-- Name: func_key_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_type ALTER COLUMN id SET DEFAULT nextval('public.func_key_type_id_seq'::regclass);


--
-- Name: groupfeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupfeatures ALTER COLUMN id SET DEFAULT nextval('public.groupfeatures_id_seq'::regclass);


--
-- Name: iaxcallnumberlimits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iaxcallnumberlimits ALTER COLUMN id SET DEFAULT nextval('public.iaxcallnumberlimits_id_seq'::regclass);


--
-- Name: incall id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incall ALTER COLUMN id SET DEFAULT nextval('public.incall_id_seq'::regclass);


--
-- Name: ivr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr ALTER COLUMN id SET DEFAULT nextval('public.ivr_id_seq'::regclass);


--
-- Name: ivr_choice id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr_choice ALTER COLUMN id SET DEFAULT nextval('public.ivr_choice_id_seq'::regclass);


--
-- Name: linefeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures ALTER COLUMN id SET DEFAULT nextval('public.linefeatures_id_seq'::regclass);


--
-- Name: mail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail ALTER COLUMN id SET DEFAULT nextval('public.mail_id_seq'::regclass);


--
-- Name: monitoring id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monitoring ALTER COLUMN id SET DEFAULT nextval('public.monitoring_id_seq'::regclass);


--
-- Name: netiface id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.netiface ALTER COLUMN id SET DEFAULT nextval('public.netiface_id_seq'::regclass);


--
-- Name: outcall id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcall ALTER COLUMN id SET DEFAULT nextval('public.outcall_id_seq'::regclass);


--
-- Name: paging id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paging ALTER COLUMN id SET DEFAULT nextval('public.paging_id_seq'::regclass);


--
-- Name: parking_lot id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_lot ALTER COLUMN id SET DEFAULT nextval('public.parking_lot_id_seq'::regclass);


--
-- Name: pjsip_transport_option id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pjsip_transport_option ALTER COLUMN id SET DEFAULT nextval('public.pjsip_transport_option_id_seq'::regclass);


--
-- Name: provisioning id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provisioning ALTER COLUMN id SET DEFAULT nextval('public.provisioning_id_seq'::regclass);


--
-- Name: queue_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queue_log ALTER COLUMN id SET DEFAULT nextval('public.queue_log_id_seq'::regclass);


--
-- Name: queuefeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuefeatures ALTER COLUMN id SET DEFAULT nextval('public.queuefeatures_id_seq'::regclass);


--
-- Name: queuepenalty id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuepenalty ALTER COLUMN id SET DEFAULT nextval('public.queuepenalty_id_seq'::regclass);


--
-- Name: queueskill id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskill ALTER COLUMN id SET DEFAULT nextval('public.queueskill_id_seq'::regclass);


--
-- Name: queueskillcat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillcat ALTER COLUMN id SET DEFAULT nextval('public.queueskillcat_id_seq'::regclass);


--
-- Name: queueskillrule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillrule ALTER COLUMN id SET DEFAULT nextval('public.queueskillrule_id_seq'::regclass);


--
-- Name: resolvconf id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resolvconf ALTER COLUMN id SET DEFAULT nextval('public.resolvconf_id_seq'::regclass);


--
-- Name: rightcall id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcall ALTER COLUMN id SET DEFAULT nextval('public.rightcall_id_seq'::regclass);


--
-- Name: rightcallexten id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallexten ALTER COLUMN id SET DEFAULT nextval('public.rightcallexten_id_seq'::regclass);


--
-- Name: rightcallmember id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallmember ALTER COLUMN id SET DEFAULT nextval('public.rightcallmember_id_seq'::regclass);


--
-- Name: sccpdevice id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpdevice ALTER COLUMN id SET DEFAULT nextval('public.sccpdevice_id_seq'::regclass);


--
-- Name: sccpgeneralsettings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpgeneralsettings ALTER COLUMN id SET DEFAULT nextval('public.sccpgeneralsettings_id_seq'::regclass);


--
-- Name: sccpline id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpline ALTER COLUMN id SET DEFAULT nextval('public.sccpline_id_seq'::regclass);


--
-- Name: schedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule ALTER COLUMN id SET DEFAULT nextval('public.schedule_id_seq'::regclass);


--
-- Name: schedule_time id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule_time ALTER COLUMN id SET DEFAULT nextval('public.schedule_time_id_seq'::regclass);


--
-- Name: stat_agent id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_agent ALTER COLUMN id SET DEFAULT nextval('public.stat_agent_id_seq'::regclass);


--
-- Name: stat_agent_periodic id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_agent_periodic ALTER COLUMN id SET DEFAULT nextval('public.stat_agent_periodic_id_seq'::regclass);


--
-- Name: stat_call_on_queue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_call_on_queue ALTER COLUMN id SET DEFAULT nextval('public.stat_call_on_queue_id_seq'::regclass);


--
-- Name: stat_queue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_queue ALTER COLUMN id SET DEFAULT nextval('public.stat_queue_id_seq'::regclass);


--
-- Name: stat_queue_periodic id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_queue_periodic ALTER COLUMN id SET DEFAULT nextval('public.stat_queue_periodic_id_seq'::regclass);


--
-- Name: stat_switchboard_queue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_switchboard_queue ALTER COLUMN id SET DEFAULT nextval('public.stat_switchboard_queue_id_seq'::regclass);


--
-- Name: staticiax id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticiax ALTER COLUMN id SET DEFAULT nextval('public.staticiax_id_seq'::regclass);


--
-- Name: staticqueue id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticqueue ALTER COLUMN id SET DEFAULT nextval('public.staticqueue_id_seq'::regclass);


--
-- Name: staticvoicemail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticvoicemail ALTER COLUMN id SET DEFAULT nextval('public.staticvoicemail_id_seq'::regclass);


--
-- Name: stats_conf id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf ALTER COLUMN id SET DEFAULT nextval('public.stats_conf_id_seq'::regclass);


--
-- Name: trunkfeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures ALTER COLUMN id SET DEFAULT nextval('public.trunkfeatures_id_seq'::regclass);


--
-- Name: usercustom id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usercustom ALTER COLUMN id SET DEFAULT nextval('public.usercustom_id_seq'::regclass);


--
-- Name: userfeatures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures ALTER COLUMN id SET DEFAULT nextval('public.userfeatures_id_seq'::regclass);


--
-- Name: useriax id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useriax ALTER COLUMN id SET DEFAULT nextval('public.useriax_id_seq'::regclass);


--
-- Name: usersip id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersip ALTER COLUMN id SET DEFAULT nextval('public.usersip_id_seq'::regclass);


--
-- Name: voicemail uniqueid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voicemail ALTER COLUMN uniqueid SET DEFAULT nextval('public.voicemail_uniqueid_seq'::regclass);


--
-- Name: accessfeatures accessfeatures_host_feature_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accessfeatures
    ADD CONSTRAINT accessfeatures_host_feature_key UNIQUE (host, feature);


--
-- Name: accessfeatures accessfeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accessfeatures
    ADD CONSTRAINT accessfeatures_pkey PRIMARY KEY (id);


--
-- Name: agent_login_status agent_login_status_extension_context_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_login_status
    ADD CONSTRAINT agent_login_status_extension_context_key UNIQUE (extension, context);


--
-- Name: agent_login_status agent_login_status_interface_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_login_status
    ADD CONSTRAINT agent_login_status_interface_key UNIQUE (interface);


--
-- Name: agent_login_status agent_login_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_login_status
    ADD CONSTRAINT agent_login_status_pkey PRIMARY KEY (agent_id);


--
-- Name: agent_membership_status agent_membership_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_membership_status
    ADD CONSTRAINT agent_membership_status_pkey PRIMARY KEY (agent_id, queue_id);


--
-- Name: agentfeatures agentfeatures_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentfeatures
    ADD CONSTRAINT agentfeatures_number_key UNIQUE (number);


--
-- Name: agentfeatures agentfeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentfeatures
    ADD CONSTRAINT agentfeatures_pkey PRIMARY KEY (id);


--
-- Name: agentglobalparams agentglobalparams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentglobalparams
    ADD CONSTRAINT agentglobalparams_pkey PRIMARY KEY (id);


--
-- Name: agentqueueskill agentqueueskill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentqueueskill
    ADD CONSTRAINT agentqueueskill_pkey PRIMARY KEY (agentid, skillid);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: application_dest_node application_dest_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_dest_node
    ADD CONSTRAINT application_dest_node_pkey PRIMARY KEY (application_uuid);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (uuid);


--
-- Name: asterisk_file asterisk_file_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file
    ADD CONSTRAINT asterisk_file_name_key UNIQUE (name);


--
-- Name: asterisk_file asterisk_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file
    ADD CONSTRAINT asterisk_file_pkey PRIMARY KEY (id);


--
-- Name: asterisk_file_section asterisk_file_section_name_asterisk_file_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_section
    ADD CONSTRAINT asterisk_file_section_name_asterisk_file_id_key UNIQUE (name, asterisk_file_id);


--
-- Name: asterisk_file_section asterisk_file_section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_section
    ADD CONSTRAINT asterisk_file_section_pkey PRIMARY KEY (id);


--
-- Name: asterisk_file_variable asterisk_file_variable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_variable
    ADD CONSTRAINT asterisk_file_variable_pkey PRIMARY KEY (id);


--
-- Name: callerid callerid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callerid
    ADD CONSTRAINT callerid_pkey PRIMARY KEY (type, typeval);


--
-- Name: callfilter callfilter_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfilter
    ADD CONSTRAINT callfilter_name_key UNIQUE (name);


--
-- Name: callfilter callfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfilter
    ADD CONSTRAINT callfilter_pkey PRIMARY KEY (id);


--
-- Name: callfiltermember callfiltermember_callfilterid_type_typeval_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfiltermember
    ADD CONSTRAINT callfiltermember_callfilterid_type_typeval_key UNIQUE (callfilterid, type, typeval);


--
-- Name: callfiltermember callfiltermember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfiltermember
    ADD CONSTRAINT callfiltermember_pkey PRIMARY KEY (id);


--
-- Name: cel cel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cel
    ADD CONSTRAINT cel_pkey PRIMARY KEY (id);


--
-- Name: conference conference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conference
    ADD CONSTRAINT conference_pkey PRIMARY KEY (id);


--
-- Name: context context_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context
    ADD CONSTRAINT context_name_key UNIQUE (name);


--
-- Name: context context_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context
    ADD CONSTRAINT context_pkey PRIMARY KEY (id);


--
-- Name: contextinclude contextinclude_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contextinclude
    ADD CONSTRAINT contextinclude_pkey PRIMARY KEY (context, include);


--
-- Name: contextmember contextmember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contextmember
    ADD CONSTRAINT contextmember_pkey PRIMARY KEY (context, type, typeval, varname);


--
-- Name: contextnumbers contextnumbers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contextnumbers
    ADD CONSTRAINT contextnumbers_pkey PRIMARY KEY (context, type, numberbeg, numberend);


--
-- Name: contexttype contexttype_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contexttype
    ADD CONSTRAINT contexttype_name_key UNIQUE (name);


--
-- Name: contexttype contexttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contexttype
    ADD CONSTRAINT contexttype_pkey PRIMARY KEY (id);


--
-- Name: dhcp dhcp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dhcp
    ADD CONSTRAINT dhcp_pkey PRIMARY KEY (id);


--
-- Name: dialaction dialaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dialaction
    ADD CONSTRAINT dialaction_pkey PRIMARY KEY (event, category, categoryval);


--
-- Name: dialpattern dialpattern_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dialpattern
    ADD CONSTRAINT dialpattern_pkey PRIMARY KEY (id);


--
-- Name: endpoint_sip endpoint_sip_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip
    ADD CONSTRAINT endpoint_sip_name_key UNIQUE (name);


--
-- Name: endpoint_sip endpoint_sip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip
    ADD CONSTRAINT endpoint_sip_pkey PRIMARY KEY (uuid);


--
-- Name: endpoint_sip_section_option endpoint_sip_section_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_section_option
    ADD CONSTRAINT endpoint_sip_section_option_pkey PRIMARY KEY (uuid);


--
-- Name: endpoint_sip_section endpoint_sip_section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_section
    ADD CONSTRAINT endpoint_sip_section_pkey PRIMARY KEY (uuid);


--
-- Name: endpoint_sip_section endpoint_sip_section_type_endpoint_sip_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_section
    ADD CONSTRAINT endpoint_sip_section_type_endpoint_sip_uuid_key UNIQUE (type, endpoint_sip_uuid);


--
-- Name: endpoint_sip_template endpoint_sip_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_template
    ADD CONSTRAINT endpoint_sip_template_pkey PRIMARY KEY (child_uuid, parent_uuid);


--
-- Name: extensions extensions_exten_context_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extensions
    ADD CONSTRAINT extensions_exten_context_key UNIQUE (exten, context);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: external_app external_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_app
    ADD CONSTRAINT external_app_pkey PRIMARY KEY (name, tenant_uuid);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: func_key_dest_agent func_key_dest_agent_agent_id_extension_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_agent
    ADD CONSTRAINT func_key_dest_agent_agent_id_extension_id_key UNIQUE (agent_id, extension_id);


--
-- Name: func_key_dest_agent func_key_dest_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_agent
    ADD CONSTRAINT func_key_dest_agent_pkey PRIMARY KEY (func_key_id, destination_type_id);


--
-- Name: func_key_dest_bsfilter func_key_dest_bsfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_bsfilter
    ADD CONSTRAINT func_key_dest_bsfilter_pkey PRIMARY KEY (func_key_id, destination_type_id, filtermember_id);


--
-- Name: func_key_dest_conference func_key_dest_conference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_conference
    ADD CONSTRAINT func_key_dest_conference_pkey PRIMARY KEY (func_key_id, destination_type_id, conference_id);


--
-- Name: func_key_dest_custom func_key_dest_custom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_custom
    ADD CONSTRAINT func_key_dest_custom_pkey PRIMARY KEY (func_key_id, destination_type_id);


--
-- Name: func_key_dest_features func_key_dest_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_features
    ADD CONSTRAINT func_key_dest_features_pkey PRIMARY KEY (func_key_id, destination_type_id, features_id);


--
-- Name: func_key_dest_forward func_key_dest_forward_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_forward
    ADD CONSTRAINT func_key_dest_forward_pkey PRIMARY KEY (func_key_id, destination_type_id, extension_id);


--
-- Name: func_key_dest_group func_key_dest_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_group
    ADD CONSTRAINT func_key_dest_group_pkey PRIMARY KEY (func_key_id, destination_type_id, group_id);


--
-- Name: func_key_dest_groupmember func_key_dest_groupmember_group_id_extension_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_groupmember
    ADD CONSTRAINT func_key_dest_groupmember_group_id_extension_id_key UNIQUE (group_id, extension_id);


--
-- Name: func_key_dest_groupmember func_key_dest_groupmember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_groupmember
    ADD CONSTRAINT func_key_dest_groupmember_pkey PRIMARY KEY (func_key_id, destination_type_id);


--
-- Name: func_key_dest_paging func_key_dest_paging_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_paging
    ADD CONSTRAINT func_key_dest_paging_pkey PRIMARY KEY (func_key_id, destination_type_id, paging_id);


--
-- Name: func_key_dest_park_position func_key_dest_park_position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_park_position
    ADD CONSTRAINT func_key_dest_park_position_pkey PRIMARY KEY (func_key_id, destination_type_id);


--
-- Name: func_key_dest_queue func_key_dest_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_queue
    ADD CONSTRAINT func_key_dest_queue_pkey PRIMARY KEY (func_key_id, destination_type_id, queue_id);


--
-- Name: func_key_dest_service func_key_dest_service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_service
    ADD CONSTRAINT func_key_dest_service_pkey PRIMARY KEY (func_key_id, destination_type_id, extension_id);


--
-- Name: func_key_dest_user func_key_dest_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_user
    ADD CONSTRAINT func_key_dest_user_pkey PRIMARY KEY (func_key_id, user_id, destination_type_id);


--
-- Name: func_key_destination_type func_key_destination_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_destination_type
    ADD CONSTRAINT func_key_destination_type_pkey PRIMARY KEY (id);


--
-- Name: func_key_mapping func_key_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_mapping
    ADD CONSTRAINT func_key_mapping_pkey PRIMARY KEY (template_id, func_key_id, destination_type_id);


--
-- Name: func_key_mapping func_key_mapping_template_id_position_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_mapping
    ADD CONSTRAINT func_key_mapping_template_id_position_key UNIQUE (template_id, "position");


--
-- Name: func_key func_key_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key
    ADD CONSTRAINT func_key_pkey PRIMARY KEY (id, destination_type_id);


--
-- Name: func_key_template func_key_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_template
    ADD CONSTRAINT func_key_template_pkey PRIMARY KEY (id);


--
-- Name: func_key_type func_key_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_type
    ADD CONSTRAINT func_key_type_pkey PRIMARY KEY (id);


--
-- Name: groupfeatures groupfeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupfeatures
    ADD CONSTRAINT groupfeatures_pkey PRIMARY KEY (id);


--
-- Name: iaxcallnumberlimits iaxcallnumberlimits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iaxcallnumberlimits
    ADD CONSTRAINT iaxcallnumberlimits_pkey PRIMARY KEY (id);


--
-- Name: incall incall_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incall
    ADD CONSTRAINT incall_pkey PRIMARY KEY (id);


--
-- Name: infos infos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.infos
    ADD CONSTRAINT infos_pkey PRIMARY KEY (uuid);


--
-- Name: ingress_http ingress_http_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingress_http
    ADD CONSTRAINT ingress_http_pkey PRIMARY KEY (uuid);


--
-- Name: ingress_http ingress_http_tenant_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingress_http
    ADD CONSTRAINT ingress_http_tenant_uuid_key UNIQUE (tenant_uuid);


--
-- Name: ivr_choice ivr_choice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr_choice
    ADD CONSTRAINT ivr_choice_pkey PRIMARY KEY (id);


--
-- Name: ivr ivr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr
    ADD CONSTRAINT ivr_pkey PRIMARY KEY (id);


--
-- Name: line_extension line_extension_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.line_extension
    ADD CONSTRAINT line_extension_pkey PRIMARY KEY (line_id, extension_id);


--
-- Name: linefeatures linefeatures_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_name_key UNIQUE (name);


--
-- Name: linefeatures linefeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_pkey PRIMARY KEY (id);


--
-- Name: mail mail_origin_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail
    ADD CONSTRAINT mail_origin_key UNIQUE (origin);


--
-- Name: mail mail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail
    ADD CONSTRAINT mail_pkey PRIMARY KEY (id);


--
-- Name: meeting_authorization meeting_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_authorization
    ADD CONSTRAINT meeting_authorization_pkey PRIMARY KEY (uuid);


--
-- Name: meeting meeting_number_tenant_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting
    ADD CONSTRAINT meeting_number_tenant_uuid_key UNIQUE (number, tenant_uuid);


--
-- Name: meeting_owner meeting_owner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_owner
    ADD CONSTRAINT meeting_owner_pkey PRIMARY KEY (meeting_uuid, user_uuid);


--
-- Name: meeting meeting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting
    ADD CONSTRAINT meeting_pkey PRIMARY KEY (uuid);


--
-- Name: moh moh_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moh
    ADD CONSTRAINT moh_name_key UNIQUE (name);


--
-- Name: moh moh_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moh
    ADD CONSTRAINT moh_pkey PRIMARY KEY (uuid);


--
-- Name: monitoring monitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monitoring
    ADD CONSTRAINT monitoring_pkey PRIMARY KEY (id);


--
-- Name: netiface netiface_ifname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.netiface
    ADD CONSTRAINT netiface_ifname_key UNIQUE (ifname);


--
-- Name: netiface netiface_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.netiface
    ADD CONSTRAINT netiface_pkey PRIMARY KEY (id);


--
-- Name: outcall outcall_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcall
    ADD CONSTRAINT outcall_name_key UNIQUE (name);


--
-- Name: outcall outcall_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcall
    ADD CONSTRAINT outcall_pkey PRIMARY KEY (id);


--
-- Name: outcalltrunk outcalltrunk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcalltrunk
    ADD CONSTRAINT outcalltrunk_pkey PRIMARY KEY (outcallid, trunkfeaturesid);


--
-- Name: paging paging_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paging
    ADD CONSTRAINT paging_number_key UNIQUE (number);


--
-- Name: paging paging_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paging
    ADD CONSTRAINT paging_pkey PRIMARY KEY (id);


--
-- Name: paginguser paginguser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginguser
    ADD CONSTRAINT paginguser_pkey PRIMARY KEY (pagingid, userfeaturesid, caller);


--
-- Name: parking_lot parking_lot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_lot
    ADD CONSTRAINT parking_lot_pkey PRIMARY KEY (id);


--
-- Name: pickup pickup_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup
    ADD CONSTRAINT pickup_name_key UNIQUE (name);


--
-- Name: pickup pickup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup
    ADD CONSTRAINT pickup_pkey PRIMARY KEY (id);


--
-- Name: pickupmember pickupmember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickupmember
    ADD CONSTRAINT pickupmember_pkey PRIMARY KEY (pickupid, category, membertype, memberid);


--
-- Name: pjsip_transport pjsip_transport_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pjsip_transport
    ADD CONSTRAINT pjsip_transport_name_key UNIQUE (name);


--
-- Name: pjsip_transport_option pjsip_transport_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pjsip_transport_option
    ADD CONSTRAINT pjsip_transport_option_pkey PRIMARY KEY (id);


--
-- Name: pjsip_transport pjsip_transport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pjsip_transport
    ADD CONSTRAINT pjsip_transport_pkey PRIMARY KEY (uuid);


--
-- Name: provisioning provisioning_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provisioning
    ADD CONSTRAINT provisioning_pkey PRIMARY KEY (id);


--
-- Name: queue_log queue_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queue_log
    ADD CONSTRAINT queue_log_pkey PRIMARY KEY (id);


--
-- Name: queue queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (name);


--
-- Name: queuefeatures queuefeatures_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuefeatures
    ADD CONSTRAINT queuefeatures_name_key UNIQUE (name);


--
-- Name: queuefeatures queuefeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuefeatures
    ADD CONSTRAINT queuefeatures_pkey PRIMARY KEY (id);


--
-- Name: queuemember queuemember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuemember
    ADD CONSTRAINT queuemember_pkey PRIMARY KEY (queue_name, interface);


--
-- Name: queuemember queuemember_queue_name_channel_interface_usertype_userid_ca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuemember
    ADD CONSTRAINT queuemember_queue_name_channel_interface_usertype_userid_ca_key UNIQUE (queue_name, channel, interface, usertype, userid, category, "position");


--
-- Name: queuepenalty queuepenalty_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuepenalty
    ADD CONSTRAINT queuepenalty_name_key UNIQUE (name);


--
-- Name: queuepenalty queuepenalty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuepenalty
    ADD CONSTRAINT queuepenalty_pkey PRIMARY KEY (id);


--
-- Name: queuepenaltychange queuepenaltychange_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuepenaltychange
    ADD CONSTRAINT queuepenaltychange_pkey PRIMARY KEY (queuepenalty_id, seconds);


--
-- Name: queueskill queueskill_name_tenant_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskill
    ADD CONSTRAINT queueskill_name_tenant_uuid_key UNIQUE (name, tenant_uuid);


--
-- Name: queueskill queueskill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskill
    ADD CONSTRAINT queueskill_pkey PRIMARY KEY (id);


--
-- Name: queueskillcat queueskillcat_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillcat
    ADD CONSTRAINT queueskillcat_name_key UNIQUE (name);


--
-- Name: queueskillcat queueskillcat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillcat
    ADD CONSTRAINT queueskillcat_pkey PRIMARY KEY (id);


--
-- Name: queueskillrule queueskillrule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillrule
    ADD CONSTRAINT queueskillrule_pkey PRIMARY KEY (id);


--
-- Name: resolvconf resolvconf_domain_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resolvconf
    ADD CONSTRAINT resolvconf_domain_key UNIQUE (domain);


--
-- Name: resolvconf resolvconf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resolvconf
    ADD CONSTRAINT resolvconf_pkey PRIMARY KEY (id);


--
-- Name: rightcall rightcall_name_tenant_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcall
    ADD CONSTRAINT rightcall_name_tenant_uuid_key UNIQUE (name, tenant_uuid);


--
-- Name: rightcall rightcall_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcall
    ADD CONSTRAINT rightcall_pkey PRIMARY KEY (id);


--
-- Name: rightcallexten rightcallexten_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallexten
    ADD CONSTRAINT rightcallexten_pkey PRIMARY KEY (id);


--
-- Name: rightcallexten rightcallexten_rightcallid_exten_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallexten
    ADD CONSTRAINT rightcallexten_rightcallid_exten_key UNIQUE (rightcallid, exten);


--
-- Name: rightcallmember rightcallmember_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallmember
    ADD CONSTRAINT rightcallmember_pkey PRIMARY KEY (id);


--
-- Name: rightcallmember rightcallmember_rightcallid_type_typeval_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallmember
    ADD CONSTRAINT rightcallmember_rightcallid_type_typeval_key UNIQUE (rightcallid, type, typeval);


--
-- Name: sccpdevice sccpdevice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpdevice
    ADD CONSTRAINT sccpdevice_pkey PRIMARY KEY (id);


--
-- Name: sccpgeneralsettings sccpgeneralsettings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpgeneralsettings
    ADD CONSTRAINT sccpgeneralsettings_pkey PRIMARY KEY (id);


--
-- Name: sccpline sccpline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpline
    ADD CONSTRAINT sccpline_pkey PRIMARY KEY (id);


--
-- Name: schedule_path schedule_path_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule_path
    ADD CONSTRAINT schedule_path_pkey PRIMARY KEY (schedule_id, path, pathid);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (id);


--
-- Name: schedule_time schedule_time_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule_time
    ADD CONSTRAINT schedule_time_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sessid);


--
-- Name: stat_agent_periodic stat_agent_periodic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_agent_periodic
    ADD CONSTRAINT stat_agent_periodic_pkey PRIMARY KEY (id);


--
-- Name: stat_agent stat_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_agent
    ADD CONSTRAINT stat_agent_pkey PRIMARY KEY (id);


--
-- Name: stat_call_on_queue stat_call_on_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_call_on_queue
    ADD CONSTRAINT stat_call_on_queue_pkey PRIMARY KEY (id);


--
-- Name: stat_queue_periodic stat_queue_periodic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_queue_periodic
    ADD CONSTRAINT stat_queue_periodic_pkey PRIMARY KEY (id);


--
-- Name: stat_queue stat_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_queue
    ADD CONSTRAINT stat_queue_pkey PRIMARY KEY (id);


--
-- Name: stat_switchboard_queue stat_switchboard_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_switchboard_queue
    ADD CONSTRAINT stat_switchboard_queue_pkey PRIMARY KEY (id);


--
-- Name: staticiax staticiax_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticiax
    ADD CONSTRAINT staticiax_pkey PRIMARY KEY (id);


--
-- Name: staticqueue staticqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticqueue
    ADD CONSTRAINT staticqueue_pkey PRIMARY KEY (id);


--
-- Name: staticvoicemail staticvoicemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staticvoicemail
    ADD CONSTRAINT staticvoicemail_pkey PRIMARY KEY (id);


--
-- Name: stats_conf_agent stats_conf_agent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf_agent
    ADD CONSTRAINT stats_conf_agent_pkey PRIMARY KEY (stats_conf_id, agentfeatures_id);


--
-- Name: stats_conf stats_conf_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf
    ADD CONSTRAINT stats_conf_name_key UNIQUE (name);


--
-- Name: stats_conf stats_conf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf
    ADD CONSTRAINT stats_conf_pkey PRIMARY KEY (id);


--
-- Name: stats_conf_queue stats_conf_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf_queue
    ADD CONSTRAINT stats_conf_queue_pkey PRIMARY KEY (stats_conf_id, queuefeatures_id);


--
-- Name: stats_conf_xivouser stats_conf_xivouser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_conf_xivouser
    ADD CONSTRAINT stats_conf_xivouser_pkey PRIMARY KEY (stats_conf_id, user_id);


--
-- Name: switchboard_member_user switchboard_member_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard_member_user
    ADD CONSTRAINT switchboard_member_user_pkey PRIMARY KEY (switchboard_uuid, user_uuid);


--
-- Name: switchboard switchboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard
    ADD CONSTRAINT switchboard_pkey PRIMARY KEY (uuid);


--
-- Name: tenant tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (uuid);


--
-- Name: trunkfeatures trunkfeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_pkey PRIMARY KEY (id);


--
-- Name: user_external_app user_external_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_external_app
    ADD CONSTRAINT user_external_app_pkey PRIMARY KEY (name, user_uuid);


--
-- Name: user_line user_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_line
    ADD CONSTRAINT user_line_pkey PRIMARY KEY (user_id, line_id);


--
-- Name: usercustom usercustom_interface_intfsuffix_category_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usercustom
    ADD CONSTRAINT usercustom_interface_intfsuffix_category_key UNIQUE (interface, intfsuffix, category);


--
-- Name: usercustom usercustom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usercustom
    ADD CONSTRAINT usercustom_pkey PRIMARY KEY (id);


--
-- Name: userfeatures userfeatures_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_email UNIQUE (email);


--
-- Name: userfeatures userfeatures_func_key_private_template_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_func_key_private_template_id_key UNIQUE (func_key_private_template_id);


--
-- Name: userfeatures userfeatures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_pkey PRIMARY KEY (id);


--
-- Name: userfeatures userfeatures_uuid; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_uuid UNIQUE (uuid);


--
-- Name: useriax useriax_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useriax
    ADD CONSTRAINT useriax_name_key UNIQUE (name);


--
-- Name: useriax useriax_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useriax
    ADD CONSTRAINT useriax_pkey PRIMARY KEY (id);


--
-- Name: usersip usersip_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersip
    ADD CONSTRAINT usersip_name_key UNIQUE (name);


--
-- Name: usersip usersip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersip
    ADD CONSTRAINT usersip_pkey PRIMARY KEY (id);


--
-- Name: voicemail voicemail_mailbox_context_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voicemail
    ADD CONSTRAINT voicemail_mailbox_context_key UNIQUE (mailbox, context);


--
-- Name: voicemail voicemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voicemail
    ADD CONSTRAINT voicemail_pkey PRIMARY KEY (uniqueid);


--
-- Name: agent_login_status__idx__agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX agent_login_status__idx__agent_id ON public.agent_login_status USING btree (agent_id);


--
-- Name: agent_membership_status__idx__agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX agent_membership_status__idx__agent_id ON public.agent_membership_status USING btree (agent_id);


--
-- Name: agent_membership_status__idx__queue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX agent_membership_status__idx__queue_id ON public.agent_membership_status USING btree (queue_id);


--
-- Name: agentfeatures__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX agentfeatures__idx__tenant_uuid ON public.agentfeatures USING btree (tenant_uuid);


--
-- Name: application__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX application__idx__tenant_uuid ON public.application USING btree (tenant_uuid);


--
-- Name: asterisk_file_section__idx__asterisk_file_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX asterisk_file_section__idx__asterisk_file_id ON public.asterisk_file_section USING btree (asterisk_file_id);


--
-- Name: asterisk_file_variable__idx__asterisk_file_section_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX asterisk_file_variable__idx__asterisk_file_section_id ON public.asterisk_file_variable USING btree (asterisk_file_section_id);


--
-- Name: callfilter__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX callfilter__idx__tenant_uuid ON public.callfilter USING btree (tenant_uuid);


--
-- Name: cel__idx__call_log_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cel__idx__call_log_id ON public.cel USING btree (call_log_id);


--
-- Name: cel__idx__eventtime; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cel__idx__eventtime ON public.cel USING btree (eventtime);


--
-- Name: cel__idx__linkedid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cel__idx__linkedid ON public.cel USING btree (linkedid);


--
-- Name: conference__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX conference__idx__tenant_uuid ON public.conference USING btree (tenant_uuid);


--
-- Name: context__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX context__idx__tenant_uuid ON public.context USING btree (tenant_uuid);


--
-- Name: contextmember__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contextmember__idx__context ON public.contextmember USING btree (context);


--
-- Name: contextmember__idx__context_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contextmember__idx__context_type ON public.contextmember USING btree (context, type);


--
-- Name: dialaction__idx__action_actionarg1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dialaction__idx__action_actionarg1 ON public.dialaction USING btree (action, actionarg1);


--
-- Name: endpoint_sip_options_view__idx_root; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX endpoint_sip_options_view__idx_root ON public.endpoint_sip_options_view USING btree (root);


--
-- Name: endpoint_sip_section__idx__endpoint_sip_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX endpoint_sip_section__idx__endpoint_sip_uuid ON public.endpoint_sip_section USING btree (endpoint_sip_uuid);


--
-- Name: endpoint_sip_section_option__idx__endpoint_sip_section_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX endpoint_sip_section_option__idx__endpoint_sip_section_uuid ON public.endpoint_sip_section_option USING btree (endpoint_sip_section_uuid);


--
-- Name: extensions__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extensions__idx__context ON public.extensions USING btree (context);


--
-- Name: extensions__idx__exten; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extensions__idx__exten ON public.extensions USING btree (exten);


--
-- Name: extensions__idx__type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extensions__idx__type ON public.extensions USING btree (type);


--
-- Name: extensions__idx__typeval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extensions__idx__typeval ON public.extensions USING btree (typeval);


--
-- Name: features__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX features__idx__category ON public.features USING btree (category);


--
-- Name: func_key__idx__type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key__idx__type_id ON public.func_key USING btree (type_id);


--
-- Name: func_key_dest_agent__idx__agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_agent__idx__agent_id ON public.func_key_dest_agent USING btree (agent_id);


--
-- Name: func_key_dest_agent__idx__extension_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_agent__idx__extension_id ON public.func_key_dest_agent USING btree (extension_id);


--
-- Name: func_key_dest_bsfilter__idx__filtermember_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_bsfilter__idx__filtermember_id ON public.func_key_dest_bsfilter USING btree (filtermember_id);


--
-- Name: func_key_dest_features__idx__features_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_features__idx__features_id ON public.func_key_dest_features USING btree (features_id);


--
-- Name: func_key_dest_forward__idx__extension_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_forward__idx__extension_id ON public.func_key_dest_forward USING btree (extension_id);


--
-- Name: func_key_dest_groupmember__idx__extension_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_groupmember__idx__extension_id ON public.func_key_dest_groupmember USING btree (extension_id);


--
-- Name: func_key_dest_groupmember__idx__group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_groupmember__idx__group_id ON public.func_key_dest_groupmember USING btree (group_id);


--
-- Name: func_key_dest_paging__idx__paging_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_paging__idx__paging_id ON public.func_key_dest_paging USING btree (paging_id);


--
-- Name: func_key_dest_service__idx__extension_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_dest_service__idx__extension_id ON public.func_key_dest_service USING btree (extension_id);


--
-- Name: func_key_template__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX func_key_template__idx__tenant_uuid ON public.func_key_template USING btree (tenant_uuid);


--
-- Name: groupfeatures__idx__name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX groupfeatures__idx__name ON public.groupfeatures USING btree (name);


--
-- Name: groupfeatures__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX groupfeatures__idx__tenant_uuid ON public.groupfeatures USING btree (tenant_uuid);


--
-- Name: groupfeatures__idx__uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX groupfeatures__idx__uuid ON public.groupfeatures USING btree (uuid);


--
-- Name: incall__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX incall__idx__tenant_uuid ON public.incall USING btree (tenant_uuid);


--
-- Name: ingress_http__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ingress_http__idx__tenant_uuid ON public.ingress_http USING btree (tenant_uuid);


--
-- Name: ivr__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ivr__idx__tenant_uuid ON public.ivr USING btree (tenant_uuid);


--
-- Name: ivr_choice__idx__ivr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ivr_choice__idx__ivr_id ON public.ivr_choice USING btree (ivr_id);


--
-- Name: line_extension__idx__extension_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX line_extension__idx__extension_id ON public.line_extension USING btree (extension_id);


--
-- Name: line_extension__idx__line_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX line_extension__idx__line_id ON public.line_extension USING btree (line_id);


--
-- Name: linefeatures__idx__application_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__application_uuid ON public.linefeatures USING btree (application_uuid);


--
-- Name: linefeatures__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__context ON public.linefeatures USING btree (context);


--
-- Name: linefeatures__idx__device; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__device ON public.linefeatures USING btree (device);


--
-- Name: linefeatures__idx__endpoint_custom_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__endpoint_custom_id ON public.linefeatures USING btree (endpoint_custom_id);


--
-- Name: linefeatures__idx__endpoint_sccp_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__endpoint_sccp_id ON public.linefeatures USING btree (endpoint_sccp_id);


--
-- Name: linefeatures__idx__endpoint_sip_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__endpoint_sip_uuid ON public.linefeatures USING btree (endpoint_sip_uuid);


--
-- Name: linefeatures__idx__number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__number ON public.linefeatures USING btree (number);


--
-- Name: linefeatures__idx__provisioningid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX linefeatures__idx__provisioningid ON public.linefeatures USING btree (provisioningid);


--
-- Name: meeting__idx__guest_endpoint_sip_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX meeting__idx__guest_endpoint_sip_uuid ON public.meeting USING btree (guest_endpoint_sip_uuid);


--
-- Name: meeting__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX meeting__idx__tenant_uuid ON public.meeting USING btree (tenant_uuid);


--
-- Name: meeting_authorization__idx__guest_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX meeting_authorization__idx__guest_uuid ON public.meeting_authorization USING btree (guest_uuid);


--
-- Name: meeting_authorization__idx__meeting_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX meeting_authorization__idx__meeting_uuid ON public.meeting_authorization USING btree (meeting_uuid);


--
-- Name: moh__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX moh__idx__tenant_uuid ON public.moh USING btree (tenant_uuid);


--
-- Name: outcall__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX outcall__idx__tenant_uuid ON public.outcall USING btree (tenant_uuid);


--
-- Name: outcalltrunk__idx__priority; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX outcalltrunk__idx__priority ON public.outcalltrunk USING btree (priority);


--
-- Name: paging__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX paging__idx__tenant_uuid ON public.paging USING btree (tenant_uuid);


--
-- Name: paginguser__idx__pagingid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX paginguser__idx__pagingid ON public.paginguser USING btree (pagingid);


--
-- Name: parking_lot__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX parking_lot__idx__tenant_uuid ON public.parking_lot USING btree (tenant_uuid);


--
-- Name: pickup__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pickup__idx__tenant_uuid ON public.pickup USING btree (tenant_uuid);


--
-- Name: pjsip_transport_option__idx__pjsip_transport_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX pjsip_transport_option__idx__pjsip_transport_uuid ON public.pjsip_transport_option USING btree (pjsip_transport_uuid);


--
-- Name: queue__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queue__idx__category ON public.queue USING btree (category);


--
-- Name: queue_log__idx_agent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queue_log__idx_agent ON public.queue_log USING btree (agent);


--
-- Name: queue_log__idx_callid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queue_log__idx_callid ON public.queue_log USING btree (callid);


--
-- Name: queue_log__idx_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queue_log__idx_event ON public.queue_log USING btree (event);


--
-- Name: queue_log__idx_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queue_log__idx_time ON public.queue_log USING btree ("time");


--
-- Name: queuefeatures__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuefeatures__idx__context ON public.queuefeatures USING btree (context);


--
-- Name: queuefeatures__idx__number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuefeatures__idx__number ON public.queuefeatures USING btree (number);


--
-- Name: queuefeatures__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuefeatures__idx__tenant_uuid ON public.queuefeatures USING btree (tenant_uuid);


--
-- Name: queuemember__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuemember__idx__category ON public.queuemember USING btree (category);


--
-- Name: queuemember__idx__channel; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuemember__idx__channel ON public.queuemember USING btree (channel);


--
-- Name: queuemember__idx__userid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuemember__idx__userid ON public.queuemember USING btree (userid);


--
-- Name: queuemember__idx__usertype; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queuemember__idx__usertype ON public.queuemember USING btree (usertype);


--
-- Name: queueskill__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queueskill__idx__tenant_uuid ON public.queueskill USING btree (tenant_uuid);


--
-- Name: queueskillrule__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX queueskillrule__idx__tenant_uuid ON public.queueskillrule USING btree (tenant_uuid);


--
-- Name: rightcall__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rightcall__idx__tenant_uuid ON public.rightcall USING btree (tenant_uuid);


--
-- Name: sccpline__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sccpline__idx__tenant_uuid ON public.sccpline USING btree (tenant_uuid);


--
-- Name: schedule__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX schedule__idx__tenant_uuid ON public.schedule USING btree (tenant_uuid);


--
-- Name: schedule_path__idx__schedule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX schedule_path__idx__schedule_id ON public.schedule_path USING btree (schedule_id);


--
-- Name: schedule_path_path; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX schedule_path_path ON public.schedule_path USING btree (path, pathid);


--
-- Name: schedule_time__idx__scheduleid_commented; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX schedule_time__idx__scheduleid_commented ON public.schedule_time USING btree (schedule_id, commented);


--
-- Name: session__idx__expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session__idx__expire ON public.session USING btree (expire);


--
-- Name: session__idx__identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session__idx__identifier ON public.session USING btree (identifier);


--
-- Name: stat_agent__idx_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_agent__idx_name ON public.stat_agent USING btree (name);


--
-- Name: stat_agent__idx_tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_agent__idx_tenant_uuid ON public.stat_agent USING btree (tenant_uuid);


--
-- Name: stat_agent_periodic__idx__stat_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_agent_periodic__idx__stat_agent_id ON public.stat_agent_periodic USING btree (stat_agent_id);


--
-- Name: stat_agent_periodic__idx__time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_agent_periodic__idx__time ON public.stat_agent_periodic USING btree ("time");


--
-- Name: stat_call_on_queue__idx__stat_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_call_on_queue__idx__stat_agent_id ON public.stat_call_on_queue USING btree (stat_agent_id);


--
-- Name: stat_call_on_queue__idx__stat_queue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_call_on_queue__idx__stat_queue_id ON public.stat_call_on_queue USING btree (stat_queue_id);


--
-- Name: stat_call_on_queue__idx_callid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_call_on_queue__idx_callid ON public.stat_call_on_queue USING btree (callid);


--
-- Name: stat_queue__idx_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_queue__idx_name ON public.stat_queue USING btree (name);


--
-- Name: stat_queue__idx_tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_queue__idx_tenant_uuid ON public.stat_queue USING btree (tenant_uuid);


--
-- Name: stat_queue_periodic__idx__stat_queue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_queue_periodic__idx__stat_queue_id ON public.stat_queue_periodic USING btree (stat_queue_id);


--
-- Name: stat_switchboard_queue__idx__queue_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_switchboard_queue__idx__queue_id ON public.stat_switchboard_queue USING btree (queue_id);


--
-- Name: stat_switchboard_queue__idx__time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stat_switchboard_queue__idx__time ON public.stat_switchboard_queue USING btree ("time");


--
-- Name: staticiax__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX staticiax__idx__category ON public.staticiax USING btree (category);


--
-- Name: staticqueue__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX staticqueue__idx__category ON public.staticqueue USING btree (category);


--
-- Name: staticvoicemail__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX staticvoicemail__idx__category ON public.staticvoicemail USING btree (category);


--
-- Name: stats_conf__idx__disable; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stats_conf__idx__disable ON public.stats_conf USING btree (disable);


--
-- Name: switchboard__idx__hold_moh_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX switchboard__idx__hold_moh_uuid ON public.switchboard USING btree (hold_moh_uuid);


--
-- Name: switchboard__idx__queue_moh_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX switchboard__idx__queue_moh_uuid ON public.switchboard USING btree (queue_moh_uuid);


--
-- Name: switchboard__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX switchboard__idx__tenant_uuid ON public.switchboard USING btree (tenant_uuid);


--
-- Name: switchboard_member_user__idx__switchboard_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX switchboard_member_user__idx__switchboard_uuid ON public.switchboard_member_user USING btree (switchboard_uuid);


--
-- Name: switchboard_member_user__idx__user_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX switchboard_member_user__idx__user_uuid ON public.switchboard_member_user USING btree (user_uuid);


--
-- Name: tenant__idx__global_sip_template_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant__idx__global_sip_template_uuid ON public.tenant USING btree (global_sip_template_uuid);


--
-- Name: tenant__idx__meeting_guest_sip_template_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant__idx__meeting_guest_sip_template_uuid ON public.tenant USING btree (meeting_guest_sip_template_uuid);


--
-- Name: tenant__idx__registration_trunk_sip_template_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant__idx__registration_trunk_sip_template_uuid ON public.tenant USING btree (registration_trunk_sip_template_uuid);


--
-- Name: tenant__idx__twilio_trunk_sip_template_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant__idx__twilio_trunk_sip_template_uuid ON public.tenant USING btree (twilio_trunk_sip_template_uuid);


--
-- Name: tenant__idx__webrtc_sip_template_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tenant__idx__webrtc_sip_template_uuid ON public.tenant USING btree (webrtc_sip_template_uuid);


--
-- Name: trunkfeatures__idx__endpoint_custom_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__endpoint_custom_id ON public.trunkfeatures USING btree (endpoint_custom_id);


--
-- Name: trunkfeatures__idx__endpoint_iax_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__endpoint_iax_id ON public.trunkfeatures USING btree (endpoint_iax_id);


--
-- Name: trunkfeatures__idx__endpoint_sip_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__endpoint_sip_uuid ON public.trunkfeatures USING btree (endpoint_sip_uuid);


--
-- Name: trunkfeatures__idx__register_iax_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__register_iax_id ON public.trunkfeatures USING btree (register_iax_id);


--
-- Name: trunkfeatures__idx__registercommented; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__registercommented ON public.trunkfeatures USING btree (registercommented);


--
-- Name: trunkfeatures__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trunkfeatures__idx__tenant_uuid ON public.trunkfeatures USING btree (tenant_uuid);


--
-- Name: user_line__idx__line_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_line__idx__line_id ON public.user_line USING btree (line_id);


--
-- Name: user_line__idx__user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_line__idx__user_id ON public.user_line USING btree (user_id);


--
-- Name: usercustom__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usercustom__idx__category ON public.usercustom USING btree (category);


--
-- Name: usercustom__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usercustom__idx__context ON public.usercustom USING btree (context);


--
-- Name: usercustom__idx__name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usercustom__idx__name ON public.usercustom USING btree (name);


--
-- Name: usercustom__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usercustom__idx__tenant_uuid ON public.usercustom USING btree (tenant_uuid);


--
-- Name: userfeatures__idx__agentid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__agentid ON public.userfeatures USING btree (agentid);


--
-- Name: userfeatures__idx__firstname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__firstname ON public.userfeatures USING btree (firstname);


--
-- Name: userfeatures__idx__func_key_private_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__func_key_private_template_id ON public.userfeatures USING btree (func_key_private_template_id);


--
-- Name: userfeatures__idx__func_key_template_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__func_key_template_id ON public.userfeatures USING btree (func_key_template_id);


--
-- Name: userfeatures__idx__lastname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__lastname ON public.userfeatures USING btree (lastname);


--
-- Name: userfeatures__idx__loginclient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__loginclient ON public.userfeatures USING btree (loginclient);


--
-- Name: userfeatures__idx__musiconhold; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__musiconhold ON public.userfeatures USING btree (musiconhold);


--
-- Name: userfeatures__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__tenant_uuid ON public.userfeatures USING btree (tenant_uuid);


--
-- Name: userfeatures__idx__uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__uuid ON public.userfeatures USING btree (uuid);


--
-- Name: userfeatures__idx__voicemailid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userfeatures__idx__voicemailid ON public.userfeatures USING btree (voicemailid);


--
-- Name: useriax__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX useriax__idx__category ON public.useriax USING btree (category);


--
-- Name: useriax__idx__mailbox; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX useriax__idx__mailbox ON public.useriax USING btree (mailbox);


--
-- Name: useriax__idx__tenant_uuid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX useriax__idx__tenant_uuid ON public.useriax USING btree (tenant_uuid);


--
-- Name: usersip__idx__category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX usersip__idx__category ON public.usersip USING btree (category);


--
-- Name: voicemail__idx__context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX voicemail__idx__context ON public.voicemail USING btree (context);


--
-- Name: queue_log change_queue_log_agent; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER change_queue_log_agent BEFORE INSERT ON public.queue_log FOR EACH ROW WHEN ((((new.event)::text = 'PAUSEALL'::text) OR ((new.event)::text = 'UNPAUSEALL'::text))) EXECUTE PROCEDURE public.set_agent_on_pauseall();


--
-- Name: agentfeatures agentfeatures_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agentfeatures
    ADD CONSTRAINT agentfeatures_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: application_dest_node application_dest_node_application_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_dest_node
    ADD CONSTRAINT application_dest_node_application_uuid_fkey FOREIGN KEY (application_uuid) REFERENCES public.application(uuid) ON DELETE CASCADE;


--
-- Name: application application_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: asterisk_file_section asterisk_file_section_asterisk_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_section
    ADD CONSTRAINT asterisk_file_section_asterisk_file_id_fkey FOREIGN KEY (asterisk_file_id) REFERENCES public.asterisk_file(id) ON DELETE CASCADE;


--
-- Name: asterisk_file_variable asterisk_file_variable_asterisk_file_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asterisk_file_variable
    ADD CONSTRAINT asterisk_file_variable_asterisk_file_section_id_fkey FOREIGN KEY (asterisk_file_section_id) REFERENCES public.asterisk_file_section(id) ON DELETE CASCADE;


--
-- Name: callfilter callfilter_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callfilter
    ADD CONSTRAINT callfilter_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: conference conference_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conference
    ADD CONSTRAINT conference_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: context context_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context
    ADD CONSTRAINT context_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid);


--
-- Name: endpoint_sip_section endpoint_sip_section_endpoint_sip_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_section
    ADD CONSTRAINT endpoint_sip_section_endpoint_sip_uuid_fkey FOREIGN KEY (endpoint_sip_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE CASCADE;


--
-- Name: endpoint_sip_section_option endpoint_sip_section_option_endpoint_sip_section_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_section_option
    ADD CONSTRAINT endpoint_sip_section_option_endpoint_sip_section_uuid_fkey FOREIGN KEY (endpoint_sip_section_uuid) REFERENCES public.endpoint_sip_section(uuid) ON DELETE CASCADE;


--
-- Name: endpoint_sip_template endpoint_sip_template_child_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_template
    ADD CONSTRAINT endpoint_sip_template_child_uuid_fkey FOREIGN KEY (child_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE CASCADE;


--
-- Name: endpoint_sip_template endpoint_sip_template_parent_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip_template
    ADD CONSTRAINT endpoint_sip_template_parent_uuid_fkey FOREIGN KEY (parent_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE CASCADE;


--
-- Name: endpoint_sip endpoint_sip_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip
    ADD CONSTRAINT endpoint_sip_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: endpoint_sip endpoint_sip_transport_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoint_sip
    ADD CONSTRAINT endpoint_sip_transport_uuid_fkey FOREIGN KEY (transport_uuid) REFERENCES public.pjsip_transport(uuid);


--
-- Name: external_app external_app_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_app
    ADD CONSTRAINT external_app_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: func_key_dest_agent func_key_dest_agent_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_agent
    ADD CONSTRAINT func_key_dest_agent_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agentfeatures(id);


--
-- Name: func_key_dest_agent func_key_dest_agent_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_agent
    ADD CONSTRAINT func_key_dest_agent_extension_id_fkey FOREIGN KEY (extension_id) REFERENCES public.extensions(id);


--
-- Name: func_key_dest_agent func_key_dest_agent_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_agent
    ADD CONSTRAINT func_key_dest_agent_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_bsfilter func_key_dest_bsfilter_filtermember_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_bsfilter
    ADD CONSTRAINT func_key_dest_bsfilter_filtermember_id_fkey FOREIGN KEY (filtermember_id) REFERENCES public.callfiltermember(id);


--
-- Name: func_key_dest_bsfilter func_key_dest_bsfilter_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_bsfilter
    ADD CONSTRAINT func_key_dest_bsfilter_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_conference func_key_dest_conference_conference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_conference
    ADD CONSTRAINT func_key_dest_conference_conference_id_fkey FOREIGN KEY (conference_id) REFERENCES public.conference(id);


--
-- Name: func_key_dest_conference func_key_dest_conference_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_conference
    ADD CONSTRAINT func_key_dest_conference_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_custom func_key_dest_custom_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_custom
    ADD CONSTRAINT func_key_dest_custom_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_features func_key_dest_features_features_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_features
    ADD CONSTRAINT func_key_dest_features_features_id_fkey FOREIGN KEY (features_id) REFERENCES public.features(id);


--
-- Name: func_key_dest_features func_key_dest_features_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_features
    ADD CONSTRAINT func_key_dest_features_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_forward func_key_dest_forward_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_forward
    ADD CONSTRAINT func_key_dest_forward_extension_id_fkey FOREIGN KEY (extension_id) REFERENCES public.extensions(id);


--
-- Name: func_key_dest_forward func_key_dest_forward_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_forward
    ADD CONSTRAINT func_key_dest_forward_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_group func_key_dest_group_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_group
    ADD CONSTRAINT func_key_dest_group_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_group func_key_dest_group_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_group
    ADD CONSTRAINT func_key_dest_group_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groupfeatures(id);


--
-- Name: func_key_dest_groupmember func_key_dest_groupmember_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_groupmember
    ADD CONSTRAINT func_key_dest_groupmember_extension_id_fkey FOREIGN KEY (extension_id) REFERENCES public.extensions(id);


--
-- Name: func_key_dest_groupmember func_key_dest_groupmember_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_groupmember
    ADD CONSTRAINT func_key_dest_groupmember_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_groupmember func_key_dest_groupmember_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_groupmember
    ADD CONSTRAINT func_key_dest_groupmember_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groupfeatures(id);


--
-- Name: func_key_dest_paging func_key_dest_paging_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_paging
    ADD CONSTRAINT func_key_dest_paging_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_paging func_key_dest_paging_paging_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_paging
    ADD CONSTRAINT func_key_dest_paging_paging_id_fkey FOREIGN KEY (paging_id) REFERENCES public.paging(id);


--
-- Name: func_key_dest_park_position func_key_dest_park_position_func_key_id_destination_type_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_park_position
    ADD CONSTRAINT func_key_dest_park_position_func_key_id_destination_type_i_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_queue func_key_dest_queue_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_queue
    ADD CONSTRAINT func_key_dest_queue_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_queue func_key_dest_queue_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_queue
    ADD CONSTRAINT func_key_dest_queue_queue_id_fkey FOREIGN KEY (queue_id) REFERENCES public.queuefeatures(id);


--
-- Name: func_key_dest_service func_key_dest_service_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_service
    ADD CONSTRAINT func_key_dest_service_extension_id_fkey FOREIGN KEY (extension_id) REFERENCES public.extensions(id);


--
-- Name: func_key_dest_service func_key_dest_service_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_service
    ADD CONSTRAINT func_key_dest_service_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_user func_key_dest_user_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_user
    ADD CONSTRAINT func_key_dest_user_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_dest_user func_key_dest_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_dest_user
    ADD CONSTRAINT func_key_dest_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.userfeatures(id);


--
-- Name: func_key func_key_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key
    ADD CONSTRAINT func_key_destination_type_id_fkey FOREIGN KEY (destination_type_id) REFERENCES public.func_key_destination_type(id);


--
-- Name: func_key_mapping func_key_mapping_func_key_id_destination_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_mapping
    ADD CONSTRAINT func_key_mapping_func_key_id_destination_type_id_fkey FOREIGN KEY (func_key_id, destination_type_id) REFERENCES public.func_key(id, destination_type_id);


--
-- Name: func_key_mapping func_key_mapping_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_mapping
    ADD CONSTRAINT func_key_mapping_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.func_key_template(id);


--
-- Name: func_key_template func_key_template_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key_template
    ADD CONSTRAINT func_key_template_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: func_key func_key_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.func_key
    ADD CONSTRAINT func_key_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.func_key_type(id);


--
-- Name: groupfeatures groupfeatures_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupfeatures
    ADD CONSTRAINT groupfeatures_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: incall incall_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incall
    ADD CONSTRAINT incall_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: ingress_http ingress_http_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingress_http
    ADD CONSTRAINT ingress_http_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: ivr_choice ivr_choice_ivr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr_choice
    ADD CONSTRAINT ivr_choice_ivr_id_fkey FOREIGN KEY (ivr_id) REFERENCES public.ivr(id);


--
-- Name: ivr ivr_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ivr
    ADD CONSTRAINT ivr_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: line_extension line_extension_extension_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.line_extension
    ADD CONSTRAINT line_extension_extension_id_fkey FOREIGN KEY (extension_id) REFERENCES public.extensions(id) ON DELETE CASCADE;


--
-- Name: line_extension line_extension_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.line_extension
    ADD CONSTRAINT line_extension_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.linefeatures(id) ON DELETE CASCADE;


--
-- Name: linefeatures linefeatures_application_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_application_uuid_fkey FOREIGN KEY (application_uuid) REFERENCES public.application(uuid) ON DELETE SET NULL;


--
-- Name: linefeatures linefeatures_endpoint_custom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_endpoint_custom_id_fkey FOREIGN KEY (endpoint_custom_id) REFERENCES public.usercustom(id) ON DELETE SET NULL;


--
-- Name: linefeatures linefeatures_endpoint_sccp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_endpoint_sccp_id_fkey FOREIGN KEY (endpoint_sccp_id) REFERENCES public.sccpline(id) ON DELETE SET NULL;


--
-- Name: linefeatures linefeatures_endpoint_sip_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linefeatures
    ADD CONSTRAINT linefeatures_endpoint_sip_uuid_fkey FOREIGN KEY (endpoint_sip_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: meeting_authorization meeting_authorization_meeting_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_authorization
    ADD CONSTRAINT meeting_authorization_meeting_uuid_fkey FOREIGN KEY (meeting_uuid) REFERENCES public.meeting(uuid) ON DELETE CASCADE;


--
-- Name: meeting meeting_guest_endpoint_sip_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting
    ADD CONSTRAINT meeting_guest_endpoint_sip_uuid_fkey FOREIGN KEY (guest_endpoint_sip_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: meeting_owner meeting_owner_meeting_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_owner
    ADD CONSTRAINT meeting_owner_meeting_uuid_fkey FOREIGN KEY (meeting_uuid) REFERENCES public.meeting(uuid) ON DELETE CASCADE;


--
-- Name: meeting_owner meeting_owner_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_owner
    ADD CONSTRAINT meeting_owner_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.userfeatures(uuid) ON DELETE CASCADE;


--
-- Name: meeting meeting_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting
    ADD CONSTRAINT meeting_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: moh moh_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moh
    ADD CONSTRAINT moh_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: outcall outcall_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcall
    ADD CONSTRAINT outcall_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: outcalltrunk outcalltrunk_outcallid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcalltrunk
    ADD CONSTRAINT outcalltrunk_outcallid_fkey FOREIGN KEY (outcallid) REFERENCES public.outcall(id);


--
-- Name: outcalltrunk outcalltrunk_trunkfeaturesid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcalltrunk
    ADD CONSTRAINT outcalltrunk_trunkfeaturesid_fkey FOREIGN KEY (trunkfeaturesid) REFERENCES public.trunkfeatures(id);


--
-- Name: paging paging_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paging
    ADD CONSTRAINT paging_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: paginguser paginguser_pagingid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginguser
    ADD CONSTRAINT paginguser_pagingid_fkey FOREIGN KEY (pagingid) REFERENCES public.paging(id);


--
-- Name: paginguser paginguser_userfeaturesid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginguser
    ADD CONSTRAINT paginguser_userfeaturesid_fkey FOREIGN KEY (userfeaturesid) REFERENCES public.userfeatures(id);


--
-- Name: parking_lot parking_lot_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_lot
    ADD CONSTRAINT parking_lot_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: pickup pickup_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pickup
    ADD CONSTRAINT pickup_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: pjsip_transport_option pjsip_transport_option_pjsip_transport_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pjsip_transport_option
    ADD CONSTRAINT pjsip_transport_option_pjsip_transport_uuid_fkey FOREIGN KEY (pjsip_transport_uuid) REFERENCES public.pjsip_transport(uuid) ON DELETE CASCADE;


--
-- Name: queuefeatures queuefeatures_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queuefeatures
    ADD CONSTRAINT queuefeatures_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: queueskill queueskill_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskill
    ADD CONSTRAINT queueskill_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: queueskillrule queueskillrule_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.queueskillrule
    ADD CONSTRAINT queueskillrule_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: rightcall rightcall_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcall
    ADD CONSTRAINT rightcall_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: rightcallexten rightcallexten_rightcallid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rightcallexten
    ADD CONSTRAINT rightcallexten_rightcallid_fkey FOREIGN KEY (rightcallid) REFERENCES public.rightcall(id);


--
-- Name: sccpline sccpline_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sccpline
    ADD CONSTRAINT sccpline_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: schedule_path schedule_path_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule_path
    ADD CONSTRAINT schedule_path_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedule(id);


--
-- Name: schedule schedule_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: stat_agent_periodic stat_agent_periodic_stat_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_agent_periodic
    ADD CONSTRAINT stat_agent_periodic_stat_agent_id_fkey FOREIGN KEY (stat_agent_id) REFERENCES public.stat_agent(id);


--
-- Name: stat_call_on_queue stat_call_on_queue_stat_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_call_on_queue
    ADD CONSTRAINT stat_call_on_queue_stat_agent_id_fkey FOREIGN KEY (stat_agent_id) REFERENCES public.stat_agent(id);


--
-- Name: stat_call_on_queue stat_call_on_queue_stat_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_call_on_queue
    ADD CONSTRAINT stat_call_on_queue_stat_queue_id_fkey FOREIGN KEY (stat_queue_id) REFERENCES public.stat_queue(id);


--
-- Name: stat_queue_periodic stat_queue_periodic_stat_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_queue_periodic
    ADD CONSTRAINT stat_queue_periodic_stat_queue_id_fkey FOREIGN KEY (stat_queue_id) REFERENCES public.stat_queue(id);


--
-- Name: stat_switchboard_queue stat_switchboard_queue_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stat_switchboard_queue
    ADD CONSTRAINT stat_switchboard_queue_queue_id_fkey FOREIGN KEY (queue_id) REFERENCES public.queuefeatures(id) ON DELETE CASCADE;


--
-- Name: switchboard switchboard_hold_moh_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard
    ADD CONSTRAINT switchboard_hold_moh_uuid_fkey FOREIGN KEY (hold_moh_uuid) REFERENCES public.moh(uuid) ON DELETE SET NULL;


--
-- Name: switchboard_member_user switchboard_member_user_switchboard_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard_member_user
    ADD CONSTRAINT switchboard_member_user_switchboard_uuid_fkey FOREIGN KEY (switchboard_uuid) REFERENCES public.switchboard(uuid);


--
-- Name: switchboard_member_user switchboard_member_user_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard_member_user
    ADD CONSTRAINT switchboard_member_user_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.userfeatures(uuid);


--
-- Name: switchboard switchboard_queue_moh_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard
    ADD CONSTRAINT switchboard_queue_moh_uuid_fkey FOREIGN KEY (queue_moh_uuid) REFERENCES public.moh(uuid) ON DELETE SET NULL;


--
-- Name: switchboard switchboard_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.switchboard
    ADD CONSTRAINT switchboard_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: tenant tenant_global_sip_template_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_global_sip_template_uuid_fkey FOREIGN KEY (global_sip_template_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: tenant tenant_meeting_guest_sip_template_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_meeting_guest_sip_template_uuid_fkey FOREIGN KEY (meeting_guest_sip_template_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: tenant tenant_registration_trunk_sip_template_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_registration_trunk_sip_template_uuid_fkey FOREIGN KEY (registration_trunk_sip_template_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: tenant tenant_twilio_trunk_sip_template_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_twilio_trunk_sip_template_uuid_fkey FOREIGN KEY (twilio_trunk_sip_template_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: tenant tenant_webrtc_sip_template_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_webrtc_sip_template_uuid_fkey FOREIGN KEY (webrtc_sip_template_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: trunkfeatures trunkfeatures_endpoint_custom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_endpoint_custom_id_fkey FOREIGN KEY (endpoint_custom_id) REFERENCES public.usercustom(id) ON DELETE SET NULL;


--
-- Name: trunkfeatures trunkfeatures_endpoint_iax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_endpoint_iax_id_fkey FOREIGN KEY (endpoint_iax_id) REFERENCES public.useriax(id) ON DELETE SET NULL;


--
-- Name: trunkfeatures trunkfeatures_endpoint_sip_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_endpoint_sip_uuid_fkey FOREIGN KEY (endpoint_sip_uuid) REFERENCES public.endpoint_sip(uuid) ON DELETE SET NULL;


--
-- Name: trunkfeatures trunkfeatures_register_iax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_register_iax_id_fkey FOREIGN KEY (register_iax_id) REFERENCES public.staticiax(id) ON DELETE SET NULL;


--
-- Name: trunkfeatures trunkfeatures_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trunkfeatures
    ADD CONSTRAINT trunkfeatures_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: user_external_app user_external_app_user_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_external_app
    ADD CONSTRAINT user_external_app_user_uuid_fkey FOREIGN KEY (user_uuid) REFERENCES public.userfeatures(uuid) ON DELETE CASCADE;


--
-- Name: user_line user_line_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_line
    ADD CONSTRAINT user_line_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.linefeatures(id);


--
-- Name: user_line user_line_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_line
    ADD CONSTRAINT user_line_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.userfeatures(id);


--
-- Name: usercustom usercustom_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usercustom
    ADD CONSTRAINT usercustom_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: userfeatures userfeatures_func_key_private_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_func_key_private_template_id_fkey FOREIGN KEY (func_key_private_template_id) REFERENCES public.func_key_template(id);


--
-- Name: userfeatures userfeatures_func_key_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_func_key_template_id_fkey FOREIGN KEY (func_key_template_id) REFERENCES public.func_key_template(id) ON DELETE SET NULL;


--
-- Name: userfeatures userfeatures_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: userfeatures userfeatures_voicemailid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.userfeatures
    ADD CONSTRAINT userfeatures_voicemailid_fkey FOREIGN KEY (voicemailid) REFERENCES public.voicemail(uniqueid);


--
-- Name: useriax useriax_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.useriax
    ADD CONSTRAINT useriax_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- Name: usersip usersip_tenant_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usersip
    ADD CONSTRAINT usersip_tenant_uuid_fkey FOREIGN KEY (tenant_uuid) REFERENCES public.tenant(uuid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

