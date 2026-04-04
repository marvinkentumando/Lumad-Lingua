import React from 'react';

interface GuestLayoutProps {
  children: React.ReactNode;
}

const GuestLayout: React.FC<GuestLayoutProps> = ({ children }) => {
  return (
    <div className="min-h-screen bg-forest text-cream font-body selection:bg-primary selection:text-forest">
      {children}
    </div>
  );
};

export default GuestLayout;
