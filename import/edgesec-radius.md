Conceptual Design for a Multi-Tenant, Certificate-Based
Authentication System Using HashiCorp Vault, Authentik,
Smallstep CA, FreeRADIUS, and NetBox
Introduction
Designinganend-to-end,certificate-basedauthenticationsystemthatservesmultipletenants
securelyandefficientlypresentsacomplexarchitecturalchallenge.Organizationsaimingfor
scalability,robustauditability,andflexibleautomationmustintegrateseveralbest-in-classtools
andframeworks.Thisreportintroducesacomprehensiveconceptualdesignthatleverages
HashiCorpVault,Authentik,SmallstepCA,FreeRADIUS,andNetBoxtorealizeamulti-tenant,
certificate-drivenauthenticationsystem.
ThearchitectureemphasizesHashiCorpVaultasthecentralauthorityforcredentialgeneration
andstorage,AuthentikfordeviceenrollmentleveragingOIDC,SmallstepCAforautomated
certificateissuance,FreeRADIUSforrobustEAP-TLSauthentication,andNetBoxasthe
authoritativedevicemetadatarepository.Integrationandconfigurationworkflowsarefully
automatedviaAnsible,enablingconsistent,repeatableinfrastructure-as-codedeployments.
Thefollowingsectionsexploretheconceptualarchitecture,majorcomponentroles,detailed
workflowsforbothautomationandmanualinteractions,andsupplyaMermaiddiagram
visualizingtheAnsibleautomationpipelinewithspecificroles,subtasks,andhandlers.
1. Architectural Overview
Awell-designedmulti-tenantauthenticationinfrastructureensuresstrongisolation,
automation,andobservabilitywhilescalingseamlesslyacrossorganizationalteamsor
externalcustomers.Thefollowingillustrationsummarizestherelationshipsamongthesystem’s
corecomponents:
(Tenants)
|
+-->[Authentik(OIDCEnrollment)]
|
[HashiCorpVault]
/|\
[VaultNamespaces][PKIEngine]---[SmallstepCA]---[CertificateIssuanceAPI]
|\
[VaultAPI][Webhook/Automation]
||
[AnsibleAutomation]|
||
[NetBox(DeviceMetadata)]-----/
1
|
[FreeRADIUS(EAP-TLS)]
Withinthisdiagram:
TenantisolationisachievedviaVaultnamespacesandpolicyconstraints.
▪
AutomatedenrollmentandauthenticationrelyonOIDCflows,PKIAPIs,andSAML/OAuth
▪
integrations.
AllinteractionsandupdatesareorchestratedbyAnsible,communicatingviaRESTAPIsto
▪
ensureidempotentinfrastructuredefinitionandcompliance.
1.
2. Component Roles and Functions
Thefollowingsectionselaborateoneachprimarysystemcomponent,delvingintoconfiguration,
workflows,andintegrationstrategiestailoredformulti-tenancy.
2.1 HashiCorp Vault: Multi-Tenancy and Credential Management
VaultNamespaces-IsolatedTrustDomains
VaultEnterprise’snamespacefeaturecreatesself-contained“mini-Vaults”toenforcetenant
isolation,wherebysecrets,policies,tokens,andidentitygroupsareuniquetoeachnamespace.
Thisapproachsupportsa"Vault-as-a-Service"model,allowingdelegatedadministrationto
tenant-specificteamswithoutriskofsecretsleakageorpolicycollision[2][3].
Namespacesprovide:
Per-tenantAuthMethods:Separateauthenticationbackends(OIDC,LDAP,etc.)canbe
▪
configuredineachnamespace.
IsolatedPKIEngines:Certificateissuanceisscopeduniquelyforeachtenant,ensuring
▪
tenantscannotretrieveorrevokecertificatesoutsidetheirnamespace.
StrictAccessControls:ACLsareenforcedpernamespace,supportingcustomer-orteam-
▪
specificcomplianceregimes.
1.
NamespacemanagementcanbeperformedviabothCLIandAPI:
#Createarootnamespacefor'engineering'
vaultnamespacecreateengineering
#Createasub-namespacefor'dev'team
vaultnamespacecreate-namespace=engineeringdev
APIUsageExample:
curl--header"X-Vault-Token:$VAULT_TOKEN"--requestPOST\
$VAULT_ADDR/v1/sys/namespaces/<namespace_name>
Tokensarenamespace-scoped;authenticationviatheAPIorUIrequiresspecifyingthetarget
namespaceeitherwiththeX-Vault-Namespaceheaderorintherequestpath[2].
2
PKISecretsEngine-CertificateIssuanceandLifecycle
Vault’sPKIsecretsenginedynamicallygenerates,signs,andmanagesX.509certificatesneeded
fordevice(client/server)authentication,bypassingmanualCSRandsigningworkflows
commonlyassociatedwithlegacyCAs.Keyfeaturesaddressingmulti-tenantrequirements
include:
Ephemeral/Short-livedCertificates:Reducestheattacksurfaceandeliminatesheavy
▪
revocationrecordmaintenance.
Root/IntermediateCAManagement:Eachnamespace(tenant)canoperateitsownCA
▪
hierarchy,furtherenforcingtrustseparation.
Policy-basedIssuance:Roleconfigurationsstrictlydefinealloweddomains,keyusages,
▪
extensions,andmaximumTTLpertenant[5][6].
1.
Certificateissuanceworkflow:
#EnablePKIengineinspecificnamespace
VAULT_NAMESPACE=engineering/devvaultsecretsenable-path=pkipki
#TunetheengineforlongTTLs
VAULT_NAMESPACE=engineering/devvaultsecretstune-max-lease-ttl=8760hpki
#GenerateaRootCA
VAULT_NAMESPACE=engineering/devvaultwritepki/root/generate/internal\
common_name="EngineeringDevRootCA"ttl=8760h
#Definetenants'PKIrole(limitations)
VAULT_NAMESPACE=engineering/devvaultwritepki/roles/dev-team\
allowed_domains=dev.example.com\
allow_subdomains=truemax_ttl=168h
#Issueacertificate
VAULT_NAMESPACE=engineering/devvaultwritepki/issue/dev-team\
common_name=device01.dev.example.com
API-basedcertificatemanagement,renewal,andrevocationareequallysupported.
IntegrationwithAuthentik(OIDC)andExternalAPIs
Vault’sextensibilityallowsconfigurationofauthenticationbackendsper-namespace,including
OIDCintegrationswithAuthentik.Policiesandexternalgroupbindingsensurepolicydecisions
andauthorizationarecontrolledandauditableacrossdomains[8].
2.2 Authentik: OIDC-Based Device Enrollment
Authentikisafullyopen-sourceidentityprovidercapableofmanagingauthenticationforusers,
devices,andservicesviaOAuth2/OIDC.Inthisarchitecture:
3
Device/EntityEnrollment:UsersordevicesinitiateenrollmentusingAuthentik’sOIDC
▪
deviceorbrowser-basedflows,bindingidentityclaimstodevicemetadata.
GroupandPolicyMapping:OIDCscopesandclaimsdefineauthorizationandmappingto
▪
Vaultidentitiesforgranularroleassignments.
IntegrationwithVault:AuthentikactsastheupstreamOIDCidentityproviderforVault’s
▪
oidcauthenticationmethod,enablingseamlesssinglesign-onandpolicyenforcement[8][9].
1.
Atypicalenrollmentflow:
1. DevicetriggersdevicecodeflowwithAuthentik,receivingadevicecodeandverificationURI.
2. Userauthenticates(inbrowserormobile)againstAuthentikandgrantsdeviceauthorization.
3. AuthentikissuesanOIDCaccesstokenincludingrequestedclaims/groups.
4. Thedeviceexchangesthecodeforatoken,whichisthenusedtologintoVault'sOIDC
backendintheappropriatenamespace.
1 A . uthentik-VaultOIDCintegrationsteps(abridgedforclarity)[7]:
CreateOIDCProviderandApplicationinAuthentik,withrequiredredirectURIs.
▪
EnableoidcmethodinVaultandconfigurewithAuthentik’sdiscoveryURL,clientID/secret.
▪
MapgroupsviaOIDCclaimsforauthorization.
▪
Assignnamespace-specificrolesandpolicies.
▪
1.
Theresultisautomated,securedeviceonboardingleveragingbothuseranddeviceidentity,
withfullpolicyenforcementinVault.
2.3 Smallstep CA: Automated Certificate Issuance
SmallstepCA("step-ca")isacloud-nativecertificateauthoritydesignedforautomationand
integrationindynamicenvironments,suchasmicroservices,containerizedinfrastructure,or
multi-tenantSaaS.Itfitsintothearchitectureinseveralways:
API-DrivenCertificateLifecycle:ExposesJSON/HTTPSAPIendpointsforprogrammatically
▪
requesting,renewing,andrevokingcertificates[11].
ProvisionersforTrustOnboarding:Supportsvariousprovisioners(OIDC,JWK,cloudIIDs)
▪
fortightlycontrollingandautomatingidentityandtrust.
Short-livedCertificatesandPassiveRevocation:Encouragesconfigurationsthatminimize
▪
theriskandoverheadofrevokedbutunexpiredcertificates.
IntegrationwithVaultandAnsible:CanserveasadownstreamCAforVault'sPKIengine,
▪
orasadirectcertificateissuerforEAP-TLSclients,orchestratedbyAnsiblemodulesorroles.
1.
Typicalcertificateissuanceworkflow:
1. DeviceorsystembootstrapstrusttoSmallstepCAbydownloadingrootcertificateand
verifyingagainsttheCA’sfingerprint.
2. DeviceauthenticatesusingOIDC/JWKtoken(viaAuthentikorautomationtools).
3. DevicegeneratesakeypairandCSR,submitstotheCAviaAPIorCLI.
4
4. CAvalidatesidentityandissuesasignedcertificate.
5. RenewalisautomatedusingtheShort-livedcertificatesoractiverenewalcommands.
1 S . ampleAnsibleroleusage(withmaxhoesel.smallstep.step_cacollection)[13]:
-hosts:ca-servers
roles:
-role:maxhoesel.smallstep.step_ca
step_ca_name:"OrgInternalCA"
step_ca_root_password:"supersecret"
Forclients:
-hosts:clients
roles:
-role:maxhoesel.smallstep.step_bootstrap_host
step_bootstrap_ca_url:"https://ca.org.internal"
step_bootstrap_fingerprint:"{{ca_fingerprint}}"
Andforissuingcertificates:
-name:IssuecertfordeviceA
maxhoesel.smallstep.step_ca_certificate:
ca_url:https://ca.org.internal
root:/etc/step-ca/certs/root_ca.crt
subject:deviceA.example.org
...
Thissetupstreamlinesdeviceprovisioningandrenewal,ensuringeverydevice’sidentityis
proactivelymanaged.
2.4 FreeRADIUS: EAP-TLS Device Authentication
FreeRADIUSistheworld’smostwidelydeployedRADIUSserver,supportingextensible
authenticationprotocolsincludingEAP-TLS.Itsroleinthissystem:
EAP-TLSAuthentication:Providescertificate-basedauthenticationfornetworkaccess(wired
▪
orwireless),leveragingcertificatesissuedbySmallstepCAorVaultPKI.
Multi-TenancyviaPolicies:DifferentEAP-TLSconfigurationprofilesoradditionalvirtual
▪
serverscanensuretenantseparationofauthenticationdomains.
CertificateValidation:Validatespresentedclientcertificates(fromSmallstepCA/VaultPKI),
▪
ensuresCRL/OCSPcompliance,andcanmapdeviceidentitiestonetworkVLANsoraccess
policies.
1.
Workflow:
1. DevicepresentscertificatetoRADIUSserverduringEAP-TLShandshake.
2. FreeRADIUSvalidatesthecertificatechain,checksCRL/OCSPforrevocation.
5
3. Onsuccessfulvalidation,networkaccessisgrantedanddevicemetadata(e.g.,MAC,tenant
group)canbecross-referencedwithNetBoxorVaultpolicies.
4. Periodicre-authenticationandsessionterminationcanbeconfiguredforadditionalsecurity.
1.
Configurationsummary:
DeployEAP-TLSprofile;linkCAroot/intermediate,client,andservercertificates.
▪
Tunerevocationandcipherparametersforcompliance.
▪
Integratewithdevicemetadatasource(e.g.,NetBox,optionallyviacustomPythonscripts)for
▪
adaptiveauthorization.
1 E . xampleEAP-TLSsettings(in/etc/raddb/mods-available/eap)[15][16]:
eap{
default_eap_type=tls
tls-configtls-common{
private_key_file=/etc/ssl/private/radius.key
certificate_file=/etc/ssl/certs/radius.crt
ca_file=/etc/ssl/certs/ca.crt
...
}
}
RevocationlistsandrenewallogicareupdatedintandemwithSmallstepCAorVaultPKI
workflows.
2.5 NetBox: Device Metadata Management
NetBoxisanextensible,API-drivensourceoftruthfornetworkautomationanddevice
metadata.Integrationpointsinthisarchitectureinclude:
DeviceInventoryandMetadataStore:Maintainsauthoritativerecordsondevicelifecycle,
▪
physical/logicallocation,ownership,andcustommetadatarequiredforauthenticationand
accesspolicydetermination.
APIIntegration:ExposesRESTendpointsforqueryingandupdatingdeviceobjects,custom
▪
fields(e.g.,certificateserials,enrollmentstatus),andrelationships.
DynamicInventoryforAnsible:Thenetbox.netbox.nb_inventorypluginimportsdevice
▪
inventoryandhostvariablesdirectlytoAnsibleplaybooksforautomation.
1.
Commonworkflows:
Deviceregistrationandmetadataupdateaspartoftheonboardingprocess(viaAnsible).
▪
Enrichmentofdevicerecordswithcertificateserials,expirationdates,andstatus.
▪
ConditioningofFreeRADIUSornetworkpolicyassignmentsbasedondevicedatafetched
▪
fromNetBox.
1.
ExampleNetBoxAPIinteraction:
6
-name:CreateDeviceinNetBox
netbox.netbox.netbox_device:
netbox_url:"https://netbox.example.com"
netbox_token:"{{netbox_api_token}}"
data:
name:device01
site:"HQ"
device_role:"Workstation"
RESTAPIExample[18]:
curl-H"Authorization:Token$TOKEN"\
https://netbox.local/api/dcim/devices/
NetBox’sautomation-readyintegrationsfacilitateclosed-loopupdatesfromcertificateissuance,
renewal,andrevocationworkflows.
3. End-to-End Workflow: Device Enrollment to Authenticated Access
Thearchitecture’send-to-enddeviceworkflowbringstogetherallprimarycomponents,
orchestratedbyAnsible.Thecanonicalflowforenrollinganewdevice,issuingcredentials,and
enablingauthenticatednetworkaccessincludes:
1. DeviceOIDCEnrollmentInitiation
TriggeredviaAuthentikdeviceflow,userauthenticates,andpolicy/claimsarerecorded.
▪
11..
2. DeviceMetadataUpdateinNetBox
AnsibleplaybookupdatesNetBoxwiththeinitialdevicerecordandlinksidentity/group
▪
membership.
112...
3. VaultCredentialGeneration(ifneeded)
VaultPKIenginegeneratesephemeralcertificateorsecrets,possiblyintegratingwith
▪
SmallstepCAasissuingauthority,withintenantnamespace.
1123....
4. AutomatedCertificateIssuance
DevicegeneratesCSRandrequestscertificateviaSmallstepCA,authenticatingwith
▪
OIDC/JWKtokenordelegatedVaultpolicy.
Certificate(andkey)aresecurelystoredonthedevice;serialandexpiryarepushedback
▪
toNetBox.
11234.....
5. FreeRADIUSConfigurationSync
CertificatesandrevocationlistsareupdatedontheRADIUSserver(s);EAP-TLSprofile
▪
configuredfornewtenantordevice.
PolicyandVLANmappingmaybefetchedliveviaNetBoxRESTAPI.
▪
112345......
6. NetworkAuthenticationandAccess
Deviceconnectstonetwork;FreeRADIUSvalidatesitscertificate.
▪
7
Uponsuccessfulauthentication,deviceisgrantedappropriateVLANoraccessrights.
▪
1123456.......
7. OngoingLifecycleOperations
Certificatesarerenewedviaautomation.
▪
RevokedorexpiredcertificatesaresynchronizedbetweenSmallstepCA/Vaultand
▪
FreeRADIUS.
DevicedecommissioningupdatesNetBox,triggerscertrevocation.
▪
112345671.........
4. Ansible Automation and Mermaid Workflow Diagram
TheentirelifecycleisorchestratedbyAnsible,usingmodularrolesandtasksforstepwise,
auditableconfigurationandAPIcommunication.ThefollowingMermaiddiagramillustratesa
conceptualworkflow,highlightingroles,subtasks,variables,andhandlers[19][21].
flowchartTD
subgraphAnsible_Playbook
VAULT[Role:VaultNamespaceSetup]
VAULT_POLICIES[Role:VaultPolicyManagement]
PKI[Role:VaultPKI/SmallstepCAIntegration]
AUTHENTIK[Role:AuthentikOIDCEnrollment]
NETBOX[Role:NetBoxDeviceMetadata]
FREERADIUS[Role:FreeRADIUSConfiguration]
end
**VAULT-->VAULT_POLICIES**
**VAULT_POLICIES-->PKI**
**PKI-->AUTHENTIK**
**AUTHENTIK-->NETBOX**
**NETBOX-->FREERADIUS**
subgraphPKI_Details
PKI_SETUP["Task:EnablePKIEngine"]
PKI_ISSUE["Task:Issue/SignCertificates"]
PKI_RENEW["Handler:ScheduleRenewal"]
end
**PKI-->PKI_SETUP**
**PKI_SETUP-->PKI_ISSUE**
**PKI_ISSUE-->PKI_RENEW**
subgraphAuthentik_Flow
AUTH_ENROLL["Subtask:DeviceEnrollmentviaOIDC"]
AUTH_TOKEN["Task:IssueOIDCToken"]
end
8
**AUTHENTIK-->AUTH_ENROLL**
**AUTH_ENROLL-->AUTH_TOKEN**
subgraphNetBox_Sync
NB_UPDATE["Task:DeviceRecord/InventoryUpdate"]
NB_META["Subtask:WriteCertificateMetadata"]
end
**NETBOX-->NB_UPDATE**
**NB_UPDATE-->NB_META**
subgraphFreeRADIUS_Config
FR_CERTS["Task:SyncCerts/CRL"]
FR_EAPTLS["Subtask:EAP-TLSProfileSettings"]
FR_HANDLERS["Handler:RestartRADIUSServiceonChange"]
end
**FREERADIUS-->FR_CERTS**
**FR_CERTS-->FR_EAPTLS**
**FR_EAPTLS-->FR_HANDLERS**
Thisdiagramcommunicates:
Roleseparationforlogicalmodularityandscalability.
▪
Flowdependency,ensuringprerequisitesaresatisfied(e.g.,Vaultpoliciesmustexistbefore
▪
PKIsetup).
Subtasksandhandlerstodynamicallyrespondtoeventssuchascertificaterenewals,device
▪
onboarding,orpolicychanges.
Variablepassing(notshownforbrevity)betweentasksviaAnsible’sgrouporhostvariable
▪
structuresandcontextualfacts.
1.
Inreal-worldplaybooks,eachrolecontainstemplates,taskfiles,handlers(e.g.,forrestarting
daemons),anddefault/overriddenvariablesformaximumreusability[23].
5. Detailed Configuration and Implementation Recommendations
Belowarerecommendedpracticalconsiderationsandstrategiestoimplementandoperatethis
proposedarchitectureefficiently.
Multi-Tenancy Best Practices
NamespaceandPolicySegmentation(Vault):Usehierarchicalnamespacesandtightly
▪
scopeACLstoensurezerocross-tenantcredentialleakage.
Tenant-levelProvisionersandEnrollmentFlows(SmallstepCA,Authentik):Assign
▪
provisioners,OIDCproviders,andaccessrolespertenant.
9
APITokenScoping(NetBox,Vault):CreatededicatedAPItokenswithminimalrequired
▪
permissionsand,whereavailable,restrictbyIPortenant.
RBAC/ABACEnforcement:UseOIDCclaims(fromAuthentik)andintegrationpoliciesin
▪
Vault,FreeRADIUS,andNetBoxtocentralizeandautomateaccesscontrolenforcement[25].
1.
Automation and DRY Principles
AnsibleRoleReusability:Structureeachroleforencapsulation;usetemplatesanddefaults
▪
forvariables.
IdempotencyinAPICalls:Ensurere-runningplaybooksissafe,withallAPIssupporting
▪
PATCH/PUTforupdate-or-createsemantics.
HandlersforEvent-DrivenUpdates:Configurehandlerstoautomaticallyreload/restart
▪
servicesinreactiontocertificatechangesorpolicyupdates.
DynamicInventory:IntegrateNetBox’sdynamicinventoryasthecanonicalautomation
▪
source,reducingconfigdriftbetweendevicedatabaseandreality.
1.
Observability and Security
AuditLogging:Enablelogging(withuniquerequesttracking)acrossVault,FreeRADIUS,
▪
SmallstepCA,andNetBoxAPIinteractionstosupporttraceabilityandcompliance.
CertificateRevocationandRenewalPolicies:Automaterenewalschedules(e.g.,via
▪
Smallstep’sstepcarenewindaemonmode)andenforceshort-livedcertificates;use
CRL/OCSPintegrationinFreeRADIUS.
IncidentResponse:Leveragewebhooks(e.g.,fromNetBoxorVault)forrapidnotificationof
▪
certificateexpiry,revocation,oraccesspolicychanges.
1.
6. Summary Table: Component Integration Overview
Component RoleinArchitec APIIntegration AnsibleRole/Mod Multi-Tenant
ture uleExample Feature
HashiCorpVault Securecredenti RESTAPI,PKI, hashicorp_vault_ Namespaces,
al/certificate Policy setup per-tenantACL
storage
Authentik OIDCidentity OIDC,OAuth2 authentik_enroll Tenantprovider
/deviceenrollme API ment s/flavors
nt
SmallstepCA Automatedcertific StepCARESTAPI smallstep_ca_int Provisionersper
ateauthority egrate tenant
FreeRADIUS EAP-TLSauthenti RADIUS,local freeradius_install VLAN/realm
cationengine config segmentation
10
NetBox Devicemetadata RESTAPI, netbox_metadata Tagging,custom
management+ dynamicinventor fields
APIinventory y
Eachintegrationpointisdesignedtosupportautomation,scalability,androbusttenant
isolation.
7. Conclusion
ByharmoniouslycombiningthestrengthsofVault,Authentik,SmallstepCA,FreeRADIUS,and
NetBox,thisarchitecturedeliversasecure,scalable,andfullyautomatedmulti-tenant
certificate-basedauthenticationsolution.
Corebenefitsrealizedinclude:
Uncompromisedtenantisolation-ensuredbyVaultnamespaces,policyscoping,andOIDC
▪
multi-providersupport.
Securedevicelifecycleautomation-viaOIDC-baseddeviceenrollment,X.509certificatesfor
▪
EAP-TLS,andpassive/activecertificaterevocation.
Centralizedsourceoftruthandobservability-byleveragingNetBox'smodernAPI-backed
▪
deviceinventoryandintegrationwithautomationtools.
Extensibilityandopenness-incorporatingbestpracticesfromthemosttrustedopen-source
▪
authentication,authorization,andautomationsystems,facilitatingfuturegrowthand
integration.
1.
Theconceptualdesignandworkflow-includingthedetailedMermaiddiagram-canserveasthe
foundationalblueprintforfurtherdetailedimplementation,configuration,andcontinuous
improvementinyourorganization’sauthenticationinfrastructure.
EndofComprehensiveReport
References (25)
1. Securemulti-tenancywithnamespaces-Vault.
https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces
2. LearnHowtoRunaMulti-tenantVaultwiththeNewNamespacesFeature.
https://www.hashicorp.com/en/resources/multi-tenant-vault-namespaces
3. PKI-SecretsEngines.https://docs.devnetexperttraining.com/static-docs/HashiCorp-
Vault/docs/secrets/pki/
4. UsingHashiCorpVault’sPKISecretEngine.https://docs.quarkiverse.io/quarkus-vault/dev/vault-
pki.html
5. HashicorpVault-authentik.https://version-2024-
8.goauthentik.io/integrations/services/hashicorp-vault/
11
6. OAuth2/OIDCProvider.https://deepwiki.com/goauthentik/authentik/3.4-oauth2oidc-provider
7. IntegratewithHashicorpVault-authentik.
https://integrations.goauthentik.io/security/hashicorp-vault/
8. Smallstep'sstep-caasCAwithACMEsupport.https://www.networktechguy.com/smallsteps-
step-ca-as-ca-with-acme-support/
9. ansible-collection-smallstep/roles/step_ca/README.mdatmain....
https://github.com/maxhoesel-ansible/ansible-collection-
smallstep/blob/main/roles/step_ca/README.md
10.EAP-TLS:Certificate-basedauthentication-FreeRADIUS.
https://www.freeradius.org/documentation/freeradius-server/3.2.8/tutorials/eap-tls.html
11.FreeRadiusEAP-TLSconfiguration-AlpineLinux.
https://wiki.alpinelinux.org/wiki/FreeRadius_EAP-TLS_configuration
12.APIandIntegration.https://deepwiki.com/netbox-community/netbox/7-api-and-integration
13.NetBoxIntegrations.https://netboxlabs.com/docs/console/netbox-integrations/netbox-
ansible-collection/
14.GitHub-teramako/playbook2uml:CreateaPlantUML/Mermaid.jsState....
https://github.com/teramako/playbook2uml
15.AnsibleRoles:BestPracticesandExamples.
https://learnansible.dev/article/Ansible_Roles_Best_Practices_and_Examples.html
16.Architecturalapproachesforidentityinmultitenantsolutions.https://learn.microsoft.com/en-
us/azure/architecture/guide/multitenant/approaches/identity
12
