with Ada.Streams;        use Ada.Streams;
with GNAT.Sockets.MQTT;  use GNAT.Sockets.MQTT;

package MQTT_Clients is

   type MQTT_Client is new MQTT_Pier with private;

   overriding
   procedure On_Connect_Accepted (Pier            : in out MQTT_Client;
                                  Session_Present : Boolean);

   overriding
   procedure On_Connect_Rejected (Pier     : in out MQTT_Client;
                                  Response : Connect_Response);

   overriding
   procedure On_Ping_Response (Pier : in out MQTT_Client);

   overriding
   procedure On_Publish (Pier      : in out MQTT_Client;
                         Topic     : String;
                         Message   : Stream_Element_Array;
                         Packet    : Packet_Identification;
                         Duplicate : Boolean;
                         Retain    : Boolean);

   overriding
   procedure On_Subscribe_Acknowledgement
     (Pier   : in out MQTT_Client;
      Packet : Packet_Identifier;
      Codes  : Return_Code_List);

private
   type MQTT_Client is new MQTT_Pier with null record;
end MQTT_Clients;
