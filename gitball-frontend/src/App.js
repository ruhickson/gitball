import React, { useEffect, useState } from "react";

function App() {
  const [teams, setTeams] = useState([]);
  const [selectedTeam, setSelectedTeam] = useState("");
  const [players, setPlayers] = useState([]);

  useEffect(() => {
    fetch("http://localhost:8000/teams")
      .then(res => res.json())
      .then(data => {
        if (Array.isArray(data)) {
          setTeams(data);
        } else {
          setTeams([]);
          console.error("Teams API did not return an array:", data);
        }
      })
      .catch(err => {
        setTeams([]);
        console.error("Failed to fetch teams:", err);
      });
  }, []);

  useEffect(() => {
    let url = "http://localhost:8000/player_stats";
    if (selectedTeam) url += `?team_id=${selectedTeam}`;
    fetch(url)
      .then(res => res.json())
      .then(data => setPlayers(data));
  }, [selectedTeam]);

  // Soccer pitch style
  const pitchStyle = {
    minHeight: "100vh",
    background: "linear-gradient(135deg, #3ba635 60%, #2e7d32 100%)",
    border: "8px solid white",
    borderRadius: "30px",
    boxShadow: "0 0 40px 10px #2228",
    padding: 40,
    margin: 0,
    fontFamily: "'Segoe UI', 'Arial', sans-serif",
    position: "relative"
  };

  const centerCircleStyle = {
    position: "absolute",
    top: "50px",
    left: "50%",
    transform: "translateX(-50%)",
    width: "120px",
    height: "120px",
    border: "4px solid white",
    borderRadius: "50%",
    zIndex: 1,
    opacity: 0.2
  };

  const tableStyle = {
    width: "100%",
    background: "rgba(255,255,255,0.95)",
    borderCollapse: "collapse",
    borderRadius: "12px",
    overflow: "hidden",
    boxShadow: "0 2px 12px #2224"
  };

  const thStyle = {
    background: "#388e3c",
    color: "white",
    fontWeight: "bold",
    border: "2px solid #fff",
    padding: "10px"
  };

  const tdStyle = {
    border: "1px solid #b2dfdb",
    padding: "8px",
    textAlign: "center"
  };

  return (
    <div style={pitchStyle}>
      <div style={centerCircleStyle}></div>
      <h1 style={{
        color: "white",
        textShadow: "2px 2px 8px #222",
        textAlign: "center",
        fontSize: "2.5rem",
        marginBottom: 30
      }}>
        ⚽ Gitball Premier League Player Statistics 2024/25 ⚽
      </h1>
      <div style={{ textAlign: "center", marginBottom: 30 }}>
        <label style={{ color: "white", fontWeight: "bold", fontSize: "1.2rem" }}>
          Select Team:{" "}
          <select
            value={selectedTeam}
            onChange={e => setSelectedTeam(e.target.value)}
            style={{
              fontSize: "1.1rem",
              padding: "6px 12px",
              borderRadius: "6px",
              border: "2px solid #388e3c",
              background: "#e8f5e9"
            }}
          >
            <option value="">All</option>
            {teams.map(team => (
              <option key={team.team_id} value={team.team_id}>
                {team.name}
              </option>
            ))}
          </select>
        </label>
      </div>
      <table style={tableStyle}>
        <thead>
          <tr>
            <th style={thStyle}>Player</th>
            <th style={thStyle}>Team</th>
            <th style={thStyle}>Position</th>
            <th style={thStyle}>Games</th>
            <th style={thStyle}>Avg Rating</th>
            <th style={thStyle}>Yellow Cards</th>
            <th style={thStyle}>Red Cards</th>
            <th style={thStyle}>Penalties Committed</th>
            <th style={thStyle}>Penalties Missed</th>
          </tr>
        </thead>
        <tbody>
          {players.map((p, i) => (
            <tr key={i}>
              <td style={tdStyle}>{p.name}</td>
              <td style={tdStyle}>{p.team_name}</td>
              <td style={tdStyle}>{p.position}</td>
              <td style={tdStyle}>{p.games_played}</td>
              <td style={tdStyle}>{Number(p.avg_rating).toFixed(2)}</td>
              <td style={{ ...tdStyle, background: "#fffde7" }}>{p.yellow_cards}</td>
              <td style={{ ...tdStyle, background: "#ffebee" }}>{p.red_cards}</td>
              <td style={tdStyle}>{p.penalties_committed}</td>
              <td style={tdStyle}>{p.penalties_missed}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {/* Pitch lines */}
      <div style={{
        position: "absolute",
        top: 0, left: "50%", width: "4px", height: "100%",
        background: "white", opacity: 0.15, zIndex: 0
      }} />
      <div style={{
        position: "absolute",
        top: 0, left: 0, width: "100%", height: "4px",
        background: "white", opacity: 0.15, zIndex: 0
      }} />
      <div style={{
        position: "absolute",
        bottom: 0, left: 0, width: "100%", height: "4px",
        background: "white", opacity: 0.15, zIndex: 0
      }} />
    </div>
  );
}

export default App;
