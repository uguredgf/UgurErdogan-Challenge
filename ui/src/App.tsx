

import {
  ConnectButton,
  useCurrentAccount,
  useSuiClientQuery,
} from "@mysten/dapp-kit";
import { Box, Container, Flex, Heading, Separator } from "@radix-ui/themes";
import { useState } from "react";
import { WalletStatus } from "./components/WalletStatus";
import { CreateHero } from "./components/CreateHero";
import { OwnedObjects } from "./components/OwnedObjects";
import SharedObjects from "./components/SharedObjects";
import Arenas from "./components/Arenas";
import EventsHistory from "./components/EventsHistory";
import { AdminPanel } from "./components/AdminPanel";
import { networkConfig } from "./networkConfig"; 

function App() {
  const [refreshKey, setRefreshKey] = useState(0);
  const currentAccount = useCurrentAccount();
  const packageId = networkConfig.devnet.variables?.packageId;

  // Cüzdandaki nesneleri almak için en güncel ve doğru yöntem: useSuiClientQuery
  const { data: ownedObjects } = useSuiClientQuery(
    "getOwnedObjects",
    {
      owner: currentAccount?.address as string,
    },
    {
      enabled: !!currentAccount, // Bu sorgu, sadece cüzdan bağlıysa çalışır
    }
  );

  // Sahip olunan nesneler arasından AdminCap'i arıyoruz.
  // ownedObjects?.data? kısmı, veriler henüz yüklenmediyse hata vermesini engeller.
  const adminCap = ownedObjects?.data?.find((obj) =>
    obj.data?.type?.includes("::marketplace::AdminCap")
  );

  return (
    <>
      {/* Header */}
      <Flex
        position="sticky"
        px="4"
        py="3"
        justify="between"
        align="center"
        style={{
          borderBottom: "1px solid var(--gray-a2)",
          background: "var(--color-background)",
          zIndex: 10,
        }}
      >
        <Box>
          <Heading size="6">Hero NFT Marketplace</Heading>
        </Box>
        <Box>
          <ConnectButton />
        </Box>
      </Flex>

      {/* Main Content */}
      <Container size="4" style={{ padding: "24px" }}>
        <Flex direction="column" gap="8">
          <WalletStatus />
          <Separator size="4" />
          <CreateHero refreshKey={refreshKey} setRefreshKey={setRefreshKey} />
          <Separator size="4" />
          <OwnedObjects
            refreshKey={refreshKey}
            setRefreshKey={setRefreshKey}
          />

          {/* GÜVENLİ ADMIN PANELİ BÖLÜMÜ */}
          {/* Sadece adminCap ve packageId mevcut olduğunda gösterilir */}
          {adminCap && packageId && (
            <>
              <Separator size="4" />
              <Box>
                <AdminPanel
                  packageId={packageId}
                  adminCapId={adminCap.data?.objectId!}
                />
              </Box>
            </>
          )}

          <Separator size="4" />
          <SharedObjects
            refreshKey={refreshKey}
            setRefreshKey={setRefreshKey}
          />
          <Separator size="4" />
          <Arenas refreshKey={refreshKey} setRefreshKey={setRefreshKey} />
          <Separator size="4" />
          <EventsHistory />
        </Flex>
      </Container>
    </>
  );
}

export default App;