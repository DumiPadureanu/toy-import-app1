import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ShellBar } from '@ui5/webcomponents-react';

function App() {
  return (
    <Router>
      <ShellBar
        primaryTitle="Toy Import Platform"
        showNotifications
        showProductSwitch
        showCoPilot
      />
      <div style={{ padding: '2rem' }}>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/tracking" element={<DeliveryTrackingPlaceholder />} />
          <Route path="/dashboard" element={<DashboardPlaceholder />} />
          <Route path="/analytics" element={<AnalyticsPlaceholder />} />
        </Routes>
      </div>
    </Router>
  );
}

function HomePage() {
  return (
    <div>
      <h1>Welcome to Toy Import Platform</h1>
      <p>Custom React pages for interactive features</p>
    </div>
  );
}

function DeliveryTrackingPlaceholder() {
  return <div><h2>Delivery Tracking Map</h2><p>Coming soon...</p></div>;
}

function DashboardPlaceholder() {
  return <div><h2>Dashboard</h2><p>Coming soon...</p></div>;
}

function AnalyticsPlaceholder() {
  return <div><h2>Analytics</h2><p>Coming soon...</p></div>;
}

export default App;
