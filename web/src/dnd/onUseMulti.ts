//import toast from "react-hot-toast";
import { fetchNui } from '../utils/fetchNui';
import { Slot } from '../typings';

export const onUseMulti = (item: Slot) => {
  //toast.success(`Use ${item.name}`);
  if (item.metadata && item.metadata.canUseMultiple) {
    if (item.custom) {
      fetchNui('useFakeItemMulti', { event: item.event, count: item.count ?? 1 });
    }
    else {
      fetchNui('useItemMulti', { slot: item.slot, count: item.count ?? 1 });
    }
  }
};
