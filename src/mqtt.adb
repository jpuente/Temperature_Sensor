------------------------------------------------------------------------------
--                                                                          --
--          Copyright (C) 2017, Universidad Politécnica de Madrid           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
with MQTT_Clients;                 use MQTT_Clients;

with GNAT.Sockets.MQTT;            use GNAT.Sockets.MQTT;
with GNAT.Sockets.MQTT.Streams;    use GNAT.Sockets.MQTT.Streams;
with GNAT.Sockets.Server;          use GNAT.Sockets.Server;
with GNAT.Sockets.Server.Handles;  use GNAT.Sockets.Server.Handles;

with Ada.Calendar;                 use Ada.Calendar;
with GNAT.Calendar.Time_IO;        use GNAT.Calendar.Time_IO;

with Ada.Exceptions; use Ada.Exceptions;

pragma Warnings(Off);
with System.IO;           -- for debugging
pragma Warnings(On);

package body MQTT is

   Factory   : aliased Connections_Factory;
   Server    : aliased Connections_Server (Factory'Access, 0);
   Reference : Handle;

   -------------------
   -- Create_Socket --
   -------------------

   procedure Open_Socket is
   begin
      Set (Reference,
           new MQTT_Client (Listener             => Server'Unchecked_Access,
                            Input_Size           => 80,
                            Output_Size          => 80,
                            Max_Subscribe_Topics => 20));
      declare
         Client : MQTT_Client renames MQTT_Client (Ptr (Reference).all);
      begin
         -- connect to server
         Connect (Server,
                  Client'Unchecked_Access,
                  Server_Name,
                  Port);
         -- wait for actual connection
         while not Is_Connected (Client) loop -- busy waiting
            pragma Debug(System.IO.Put("."));
            delay 0.1;
         end loop;
      end;
   end Open_Socket;

   -------------
   -- Publish --
   -------------

   procedure Publish (Message_Text : String) is
   begin
      Open_Socket;

      declare
         Client : MQTT_Client renames MQTT_Client (Ptr (Reference).all);
      begin
         -- connect to broker
         Send_Connect (Client, Client_Name);
         System.IO.Put_Line(Image(Clock, "%Y-%m-%d:%H:%M:%S ")
                            & "Socket connected");

         -- publish message
         Send_Publish (Client,
                       Topic   => Topic_Text,
                       Message => Message_Text,
                       Packet  => (At_Least_Once, 13)); -- arbitrary id
         System.IO.Put_Line(Image(Clock, "%Y-%m-%d:%H:%M:%S ")
                            & "Publish " & Topic_Text & ": " & Message_Text);

         -- disconnect from broker
         delay 0.1;
         Send_Disconnect (Client);
         System.IO.Put_Line(Image(Clock, "%Y-%m-%d:%H:%M:%S ")
                            & "Socket disconnected");
      end;
   exception
      when Error : others =>
         System.IO.Put_Line("Error: " & Exception_Information (Error));
   end Publish;

begin
   System.IO.Set_Output(System.IO.Standard_Error);
end MQTT;
