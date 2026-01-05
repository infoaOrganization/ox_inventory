export type Slot = RealSlot | FakeSlot;

export type SlotBase = {
  slot: number;
  name?: string;
  count?: number;
  weight?: number;
  metadata?: {
    [key: string]: any;
  };
  durability?: number;
};

export type RealSlot = SlotBase & {
  custom?: false;
};

export type FakeSlot = SlotBase & {
  custom: true;
  event?: string;
};

export type SlotWithItem = Slot & {
  name: string;
  count: number;
  weight: number;
  durability?: number;
  price?: number;
  currency?: string;
  ingredients?: { [key: string]: number };
  duration?: number;
  image?: string;
  grade?: number | number[];
};
