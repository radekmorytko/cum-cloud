require 'rubygems'
require "test/unit"

require 'opennebula/appstage_client'

module AutoScaling

  class AppstageClientTest < Test::Unit::TestCase

    def test_shall_extract_ip
      configuration =
<<-eos
<VM>
  <ID>169</ID>
  <UID>0</UID>
  <GID>0</GID>
  <UNAME>oneadmin</UNAME>
  <GNAME>oneadmin</GNAME>
  <NAME>ubuntu-server-cum</NAME>
  <PERMISSIONS>
    <OWNER_U>1</OWNER_U>
    <OWNER_M>1</OWNER_M>
    <OWNER_A>0</OWNER_A>
    <GROUP_U>0</GROUP_U>
    <GROUP_M>0</GROUP_M>
    <GROUP_A>0</GROUP_A>
    <OTHER_U>0</OTHER_U>
    <OTHER_M>0</OTHER_M>
    <OTHER_A>0</OTHER_A>
  </PERMISSIONS>
  <LAST_POLL>1374450534</LAST_POLL>
  <STATE>3</STATE>
  <LCM_STATE>3</LCM_STATE>
  <RESCHED>0</RESCHED>
  <STIME>1374449346</STIME>
  <ETIME>0</ETIME>
  <DEPLOY_ID>one-169</DEPLOY_ID>
  <MEMORY>524288</MEMORY>
  <CPU>2</CPU>
  <NET_TX>468</NET_TX>
  <NET_RX>71368</NET_RX>
  <TEMPLATE>
    <CONTEXT>
      <AUTO_SCALING_SERVER><![CDATA[http://192.168.122.1:4567]]></AUTO_SCALING_SERVER>
      <DISK_ID><![CDATA[1]]></DISK_ID>
      <ETH0_DNS><![CDATA[192.168.122.1]]></ETH0_DNS>
      <FILES><![CDATA[/srv/context/cookbooks]]></FILES>
      <NODE><![CDATA[eyJuYW1lIjoidG9tY2F0LXdvcmtlciIsInJ1bl9saXN0IjpbInJlY2lwZVt0b21jYXRdIl19]]></NODE>
      <TARGET><![CDATA[hdb]]></TARGET>
    </CONTEXT>
    <CPU><![CDATA[1]]></CPU>
    <DISK>
      <CLONE><![CDATA[YES]]></CLONE>
      <DATASTORE><![CDATA[default]]></DATASTORE>
      <DATASTORE_ID><![CDATA[1]]></DATASTORE_ID>
      <DEV_PREFIX><![CDATA[hd]]></DEV_PREFIX>
      <DISK_ID><![CDATA[0]]></DISK_ID>
      <DRIVER><![CDATA[qcow2]]></DRIVER>
      <IMAGE><![CDATA[Ubuntu 12.04 base]]></IMAGE>
      <IMAGE_ID><![CDATA[34]]></IMAGE_ID>
      <READONLY><![CDATA[NO]]></READONLY>
      <SAVE><![CDATA[NO]]></SAVE>
      <SOURCE><![CDATA[/var/lib/one/datastores/1/cc8f9c542ed9f031f3dec73d106194f0]]></SOURCE>
      <TARGET><![CDATA[hda]]></TARGET>
      <TM_MAD><![CDATA[qcow2]]></TM_MAD>
      <TYPE><![CDATA[FILE]]></TYPE>
    </DISK>
    <GRAPHICS>
      <LISTEN><![CDATA[0.0.0.0]]></LISTEN>
      <PORT><![CDATA[6069]]></PORT>
      <TYPE><![CDATA[vnc]]></TYPE>
    </GRAPHICS>
    <MEMORY><![CDATA[512]]></MEMORY>
    <NAME><![CDATA[ubuntu-server-cum]]></NAME>
    <NIC>
      <BRIDGE><![CDATA[virbr0]]></BRIDGE>
      <IP><![CDATA[192.168.122.104]]></IP>
      <MAC><![CDATA[02:00:c0:a8:7a:68]]></MAC>
      <NETWORK><![CDATA[Internal]]></NETWORK>
      <NETWORK_ID><![CDATA[0]]></NETWORK_ID>
      <VLAN><![CDATA[NO]]></VLAN>
    </NIC>
    <OS>
      <ARCH><![CDATA[x86_64]]></ARCH>
    </OS>
    <TEMPLATE_ID><![CDATA[7]]></TEMPLATE_ID>
    <VMID><![CDATA[169]]></VMID>
  </TEMPLATE>
  <HISTORY_RECORDS>
    <HISTORY>
      <OID>169</OID>
      <SEQ>0</SEQ>
      <HOSTNAME>kvm01</HOSTNAME>
      <HID>0</HID>
      <STIME>1374449349</STIME>
      <ETIME>0</ETIME>
      <VMMMAD>vmm_kvm</VMMMAD>
      <VNMMAD>dummy</VNMMAD>
      <TMMAD>shared</TMMAD>
      <DS_LOCATION>/var/lib/one/datastores</DS_LOCATION>
      <DS_ID>0</DS_ID>
      <PSTIME>1374449349</PSTIME>
      <PETIME>1374449358</PETIME>
      <RSTIME>1374449358</RSTIME>
      <RETIME>0</RETIME>
      <ESTIME>0</ESTIME>
      <EETIME>0</EETIME>
      <REASON>0</REASON>
    </HISTORY>
  </HISTORY_RECORDS>
</VM>
eos

      appstage = AppstageClient.new({})

      expected = '192.168.122.104'
      actual = appstage.send(:extract_ip, configuration)

      assert_equal expected, actual
    end
  end
end