using System;
using FishNet;
using FishNet.Connection;
using FishNet.Managing;
using FishNet.Transporting;
using FishySteamworks;
using Steamworks;
using UnityEngine;

public class SteamManager : MonoBehaviour
{
	private static SteamManager _instance;

	private Callback<LobbyChatUpdate_t> _lobbyChatUpdateCallback;

	private Callback<SteamRelayNetworkStatus_t> _relayStatusCallback;

	[SerializeField]
	private NetworkManager _netMan;

	[SerializeField]
	private global::FishySteamworks.FishySteamworks _fishy;

	private const int MaxPlayers = 8;

	private static DisconnectReason _disconnectReason;

	public static CSteamID CurrentLobbyID { get; private set; } = CSteamID.Nil;

	public static bool IsDev { get; private set; }

	public static ESteamNetworkingAvailability RelayStatus { get; private set; } = ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_Unknown;

	public static bool IsSteamRelayReady => RelayStatus == ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_Current;

	public static string RelayStatusMessage { get; private set; } = string.Empty;

	private void Awake()
	{
		Setter.SetSingleInstance(ref _instance, this);
		_netMan.ServerManager.OnRemoteConnectionState += OnRemoteConnectionState;
	}

	private void Start()
	{
		// Local recovery uses the original offline transport.
	}

	private void OnDestroy()
	{
		if ((bool)_netMan)
		{
			_netMan.ServerManager.OnRemoteConnectionState -= OnRemoteConnectionState;
		}
		_lobbyChatUpdateCallback?.Dispose();
		_relayStatusCallback?.Dispose();
		// Steam API is not initialized by local recovery.
	}

	private void OnRemoteConnectionState(NetworkConnection connection, RemoteConnectionStateArgs args)
	{
		if (args.ConnectionState == RemoteConnectionState.Started)
		{
			PrintConnectedClientCounts($"FishNet client {connection.ClientId} connected");
		}
	}

	private void PrintConnectedClientCounts(string eventDescription)
	{
		int num = ((!(CurrentLobbyID == CSteamID.Nil)) ? SteamMatchmaking.GetNumLobbyMembers(CurrentLobbyID) : 0);
		int count = _netMan.ServerManager.Clients.Count;
		MonoBehaviour.print($"{eventDescription}. Steam lobby members: {num}; FishNet server clients: {count}.");
	}

	public static bool RefreshRelayStatus()
	{
        if (RecoveryIsolation.Enabled) { RelayStatus = ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_CannotTry; RelayStatusMessage = "Local offline recovery"; return false; }
		try
		{
			RelayStatus = SteamNetworkingUtils.GetRelayNetworkStatus(out var pDetails);
			RelayStatusMessage = pDetails.m_debugMsg;
			LogRelayStatus(pDetails);
			return IsSteamRelayReady;
		}
		catch (Exception ex)
		{
			RelayStatus = ESteamNetworkingAvailability.k_ESteamNetworkingAvailability_CannotTry;
			RelayStatusMessage = ex.Message;
			MonoBehaviour.print($"Could not query Steam Relay status: {ex}");
			return false;
		}
	}

	private void OnRelayStatusChanged(SteamRelayNetworkStatus_t status)
	{
		RelayStatus = status.m_eAvail;
		RelayStatusMessage = status.m_debugMsg;
		LogRelayStatus(status);
	}

	private static void LogRelayStatus(SteamRelayNetworkStatus_t status)
	{
		CanvasManager.OnRelayStatus(status);
	}

	public static void CreateLobby()
	{
		ConnectionManager.Instance.CreateOfflineLobby();
	}

	public static void JoinLobby(ulong lobbyID)
	{
		SteamMatchmaking.JoinLobby(new CSteamID(lobbyID));
	}

	public static void JoinFriend(CSteamID friendID)
	{
		if (SteamFriends.GetFriendGamePlayed(friendID, out var pFriendGameInfo) && pFriendGameInfo.m_gameID.AppID() == SteamUtils.GetAppID() && pFriendGameInfo.m_steamIDLobby != CSteamID.Nil)
		{
			SteamMatchmaking.JoinLobby(pFriendGameInfo.m_steamIDLobby);
		}
	}

	public static void LeaveLobby(DisconnectReason reason)
	{
		if (!(CurrentLobbyID == CSteamID.Nil) || (bool)Server.Instance)
		{
			if (CurrentLobbyID != CSteamID.Nil)
			{
				SteamMatchmaking.LeaveLobby(CurrentLobbyID);
				CurrentLobbyID = CSteamID.Nil;
			}
			_disconnectReason = reason;
			ConnectionManager.Instance.LeaveTransport();
		}
	}

	public static bool IsCurrentLobbyMember(CSteamID user)
	{
		if (CurrentLobbyID == CSteamID.Nil || user == CSteamID.Nil)
		{
			return false;
		}
		int numLobbyMembers = SteamMatchmaking.GetNumLobbyMembers(CurrentLobbyID);
		for (int i = 0; i < numLobbyMembers; i++)
		{
			if (SteamMatchmaking.GetLobbyMemberByIndex(CurrentLobbyID, i) == user)
			{
				return true;
			}
		}
		return false;
	}

	private void OnLobbyChatUpdate(LobbyChatUpdate_t param)
	{
		if (CurrentLobbyID == CSteamID.Nil || param.m_ulSteamIDLobby != CurrentLobbyID.m_SteamID)
		{
			return;
		}
		CSteamID cSteamID = new CSteamID(param.m_ulSteamIDUserChanged);
		if (cSteamID == RecoveryPlatform.GetSteamID() && (param.m_rgfChatMemberStateChange & 0x1E) != 0)
		{
			LeaveLobby(DisconnectReason.None);
		}
		else if (InstanceFinder.NetworkManager.IsServerStarted)
		{
			if ((param.m_rgfChatMemberStateChange & 0x1E) != 0)
			{
				ConnectionManager.Instance.KickSteamUserIfConnected(cSteamID);
			}
			if ((param.m_rgfChatMemberStateChange & 1) != 0)
			{
				PrintConnectedClientCounts($"Steam user {cSteamID.m_SteamID} joined the lobby");
			}
			switch (param.m_rgfChatMemberStateChange)
			{
			}
		}
	}

	private void OnLobbyEntered(LobbyEnter_t callback)
	{
		if (callback.m_EChatRoomEnterResponse != 1)
		{
			uint eChatRoomEnterResponse = callback.m_EChatRoomEnterResponse;
			if (eChatRoomEnterResponse != 2)
			{
				_ = 3;
			}
			return;
		}
		if (CurrentLobbyID != CSteamID.Nil && !InstanceFinder.NetworkManager.IsServerStarted)
		{
			MonoBehaviour.print("trying to enter lobby");
		}
		CSteamID cSteamID = new CSteamID(callback.m_ulSteamIDLobby);
		if (SteamMatchmaking.GetLobbyData(cSteamID, "version") != Application.version)
		{
			SteamMatchmaking.LeaveLobby(cSteamID);
			NetworkPrompts.ShowVersionMismatch();
		}
		else
		{
			CurrentLobbyID = cSteamID;
			ConnectionManager.Instance.JoinOnlineLobby(CurrentLobbyID);
		}
	}

	private void CloseFailedHostLobby(string error)
	{
		Debug.LogError(error);
		if (CurrentLobbyID != CSteamID.Nil)
		{
			SteamMatchmaking.SetLobbyJoinable(CurrentLobbyID, bLobbyJoinable: false);
		}
		LeaveLobby(DisconnectReason.WithUI);
		MainMenuManager.ToggleMenu(enabled: true);
	}

	private void OnLobbyCreated(LobbyCreated_t callback)
	{
		if (callback.m_eResult != EResult.k_EResultOK)
		{
			return;
		}
		CurrentLobbyID = new CSteamID(callback.m_ulSteamIDLobby);
		SteamMatchmaking.SetLobbyJoinable(CurrentLobbyID, bLobbyJoinable: false);
		if (!ConnectionManager.Instance.CreateOnlineLobby(8))
		{
			CloseFailedHostLobby($"Steam lobby {CurrentLobbyID.m_SteamID} was created, but the FishySteamworks server failed to start. Closing the lobby.");
			return;
		}
		SteamMatchmaking.SetLobbyData(CurrentLobbyID, "name", RecoveryPlatform.GetPersonaName() + "'s lobby");
		if (!SteamMatchmaking.SetLobbyData(CurrentLobbyID, "version", Application.version) || !SteamMatchmaking.SetLobbyJoinable(CurrentLobbyID, bLobbyJoinable: true))
		{
			CloseFailedHostLobby($"Steam lobby {CurrentLobbyID.m_SteamID} could not publish its metadata or become joinable. Closing the lobby.");
		}
	}

	private void OnJoinRequested(GameLobbyJoinRequested_t callback)
	{
		if (CurrentLobbyID != CSteamID.Nil)
		{
			if (CurrentLobbyID.m_SteamID == callback.m_steamIDLobby.m_SteamID)
			{
				return;
			}
			LeaveLobby(DisconnectReason.None);
		}
		SteamMatchmaking.JoinLobby(callback.m_steamIDLobby);
	}
}
