
import { useSignAndExecuteTransaction } from "@mysten/dapp-kit";
// 'Heading' bu satıra eklendi:
import { Box, Button, Flex, Heading, TextField } from "@radix-ui/themes";
import { useState } from "react";
import { changePrice } from "../utility/admin/change_price";
import { delist } from "../utility/admin/delist";

interface AdminPanelProps {
  packageId: string;
  adminCapId: string;
}

export function AdminPanel({ packageId, adminCapId }: AdminPanelProps) {
  const [listHeroId, setListHeroId] = useState("");
  const [newPrice, setNewPrice] = useState("");
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();

  const handleChangePrice = () => {
    if (!listHeroId || !newPrice) return;
    const tx = changePrice(packageId, listHeroId, newPrice, adminCapId);
    signAndExecute(
      { transaction: tx },
      {
        onSuccess: (result) => {
          console.log("Price changed successfully:", result);
          alert("Price changed successfully!");
        },
        onError: (error) => {
          console.error("Error changing price:", error);
          alert("Error changing price.");
        },
      }
    );
  };

  const handleDelist = () => {
    if (!listHeroId) return;
    const tx = delist(packageId, listHeroId, adminCapId);
    signAndExecute(
      { transaction: tx },
      {
        onSuccess: (result) => {
          console.log("Hero delisted successfully:", result);
          alert("Hero delisted successfully!");
        },
        onError: (error) => {
          console.error("Error delisting hero:", error);
          alert("Error delisting hero.");
        },
      }
    );
  };

  return (
    <Box>
      <Heading mb="4">Admin Panel</Heading>
      <Flex direction="column" gap="4">
        <TextField.Root
          placeholder="Enter ListHero ID to manage..."
          value={listHeroId}
          onChange={(e) => setListHeroId(e.target.value)}
        />
        <TextField.Root
          placeholder="Enter new price in SUI..."
          type="number"
          value={newPrice}
          onChange={(e) => setNewPrice(e.target.value)}
        />
        <Flex gap="4">
          <Button onClick={handleChangePrice}>Change Price</Button>
          <Button onClick={handleDelist} color="red">Delist Hero</Button>
        </Flex>
      </Flex>
    </Box>
  );
}