{
  services.asterisk = {
    enable = true;
    confFiles = {
      "pjsip.conf" = ''
        [global]
        type=global
        ; verified peers first
        endpoint_identifier_order=auth_username,username,ip

        ; ==========================================
        ; Transports
        ; ==========================================

        [transport-udp4]
        type=transport
        protocol=udp
        bind=172.23.99.254:5060
        local_net=172.20.0.0/14
        local_net=172.31.0.0/16
        local_net=10.0.0.0/8

        [transport-udp6]
        type=transport
        protocol=udp
        bind=[fda7:54c1:4932::]:5060
        local_net=fd00::/8

        ; ==========================================
        ; Templates
        ; ==========================================

        [phone-template](!)
        type=endpoint
        context=context-local          ; Incoming calls from this phone go here
        allow=!all,ulaw,alaw           ; Use standard audio formats
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        direct_media=no                ; Proxy media through PBX to prevent NAT issues
        trust_id_inbound=yes
        send_pai=yes

        ; ==========================================
        ; Local Extensions
        ; ==========================================

        ; Replace variables to create an extension names <EXT_NAME>
        [4201](phone-template)
        auth=4201
        aors=4201
        callerid="My Name" <<+0424384201>>

        [4201]
        type=auth
        auth_type=userpass
        username=4201
        password=SECRET_PASSWORD

        [4201]
        type=aor
        max_contacts=3   ; Allow 3 devices to register simultaneously
        remove_existing=yes

        ; ==========================================
        ; Incoming calls via ENUM
        ; ==========================================

        [peer-enum-inbound]
        type=endpoint
        context=context-enum   ; Send unknown incoming calls to ENUM context
        allow=!all,ulaw,alaw           ; Use standard audio formats
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        direct_media=no

        [peer-enum-inbound-id]
        type=identify
        endpoint=peer-enum-inbound
        ; match all dn42 subnets
        match=172.20.0.0/14
        match=172.31.0.0/16
        match=10.0.0.0/8
        match=fd00::/8

        ; ==========================================
        ; Outgoing calls via ENUM
        ; ==========================================

        [peer-enum-outbound]
        type=endpoint
        allow=!all,ulaw,alaw           ; Use standard audio formats
        send_pai=yes
      '';
      "extensions.conf" = ''
        [globals]
        ; (Optional) Global variables can go here

        ; ==========================================
        ; Inbound Routing
        ; ==========================================

        ; Calls originating from your own network.
        [context-local]

        ; 4 digits -> call local extension
        exten => _XXXX,1,Goto(ext-local,$\{EXTEN},1)

        ; starts with 042 -> add + and route out
        exten => _042X.,1,Goto(ext-routing,+$\{EXTEN},1)

        ; standard +042 dialing -> route out
        exten => _+042X.,1,Goto(ext-routing,$\{EXTEN},1)

        ; Catch-all -> add +042 and route out
        exten => _X!,1,Goto(ext-routing,+042$\{EXTEN},1)


        ; Calls originating from external networks via ENUM.
        [context-enum]

        ; starts with 00 -> replace with + and route out
        exten => _00X!,1,Goto(ext-routing,+$\{EXTEN:2},1)

        ; starts with + -> route out
        exten => _+X!,1,Goto(ext-routing,$\{EXTEN},1)

        ; Catch-all -> add + and route out
        exten => _X!,1,Goto(ext-routing,+$\{EXTEN},1)


        ; ==========================================
        ; Outbound & Local Routing
        ; ==========================================

        ; Calls destined for local networks.
        [ext-local]
        ; route <OWN_PREFIX>4201 calls to your local extension <EXT_NAME>
        exten => 4201,1,Dial(PJSIP/<EXT_NAME>,30)  ;


        ; Inter-PBX routing for both inbound and outbound calls.
        [ext-routing]

        ; route calls destined for your prefix
        exten => _<OWN_PREFIX>.,1,Goto(ext-local,$\{EXTEN:9},1)

        ; other external calls -> do ENUM lookup on tel.dn42
        exten => _+042X.,1,Set(TARGET_URI=$\{ENUMLOOKUP($\{EXTEN},sip,,,tel.dn42)})
        ; if found, dial via our outbound endpoint
        same => n,ExecIf($["$\{TARGET_URI}"!=""]?Dial(PJSIP/peer-enum-outbound/sip:$\{TARGET_URI},60))
        ; if unallocated or failed, naturally hangup
        same => n,Hangup()
      '';

      "modules.conf" = ''
        [modules]
        autoload=yes
        noload = res_xmpp.so
        noload = chan_motif.so
        noload = res_pjsip_notify.so
        noload = res_prometheus.so
        noload = res_hep_rtcp.so
        noload = res_hep_pjsip.so
        noload = res_stun_monitor.so
        noload = pbx_lua.so
        noload = pbx_ael.so
        noload = app_festival.so
        noload = app_followme.so
        noload = app_alarmreceiver.so
        noload = cdr_manager.so
        noload = cdr_sqlite3_custom.so
        noload = cel_sqlite3_custom.so
      '';
    };
  };
}
