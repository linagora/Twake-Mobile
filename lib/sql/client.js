#!/usr/bin/env node

// var child_process = require('child_process');
// child_process.execSync('npm i socket.io-client@2.3.1',{stdio:[0,1]});


const WebsocketActions = { Join : 'realtime:join', Leave : 'realtime:leave' }
  
const WebsocketEvents = {
    Connected : 'connected',
    Disconnected : 'disconnected',
    JoinSuccess : 'realtime:join:success',
    JoinError : 'realtime:join:error',
    Resource : 'realtime:resource',
    Event : 'realtime:event'
  }
  
const io = require("socket.io-client");

const socketEndpoint = 'https://web.qa.twake.app'

const socket = io.connect(socketEndpoint, { path: '/socket',reconnectionDelayMax: 10000,});

socket.on('connect', function() {
    console.log('socket.io conntected')
    socket.emit('authenticate', {"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTI5NjMyNDMsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE2MTI5NTkwNDMsIm5iZiI6MTYxMjk1OTA0Mywic3ViIjoiNjBiYzFlYzgtNmFlNS0xMWViLWI5MzUtMDI0MmFjMTIwMDA2Iiwib3JnIjp7IjYwYzlkMGNjLTZhZTUtMTFlYi04YTAwLTAyNDJhYzEyMDAwNiI6eyJyb2xlIjoib3JnYW5pemF0aW9uX2FkbWluaXN0cmF0b3IiLCJ3a3MiOnsiNjBjZGYwM2EtNmFlNS0xMWViLWI4YjEtMDI0MmFjMTIwMDA2Ijp7ImFkbSI6dHJ1ZX19fX19.0YoIBYKdzDSCa-cpNdCaEByh90DRoOP6YyfOyA2YCno"})
});

socket.on('disconnect', function(){
    console.log('socket.io  is disconnected conntected')
});

const leave = function(path,tag = 'twake'){
    socket.emit(WebsocketActions.Leave, {"name": "previous:" + path,"token":tag})
}

const join = function(path,tag = 'twake'){
    socket.emit(WebsocketActions.Join, {"name": "previous:" + path,"token":tag})
}

socket.on('authenticated', () => {
    console.log('Authenticated');

    const websocketId = '60cdf03a-6ae5-11eb-b8b1-0242ac120006'
    const userId = '60bc1ec8-6ae5-11eb-b935-0242ac120006'
    const workspaceId = ''
    const groupId = '' // это companyId
    
    join(`collections/${websocketId}`)
    join(`users/${userId}`)  // listen user
    join(`group/${groupId}`)
    join(`workspace/${workspaceId}`)
    join(`workspaces_of_user/${workspaceId}`) // workspaces list
    join(`workspace_apps/${workspaceId}`) 
    join(`workspace_users/${workspaceId}`) 
    

})

socket.on(WebsocketEvents.JoinSuccess, (data)=>{
    console.log('joinSuccess', data)
})


socket.on(WebsocketEvents.Event, (data)=>{
    console.log('realtime event', data)
})



