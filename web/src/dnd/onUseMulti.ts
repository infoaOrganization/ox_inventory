//import toast from "react-hot-toast";
import { fetchNui } from '../utils/fetchNui';
import { Slot } from '../typings';

export const onUseMulti = (item: Slot) => {
  //toast.success(`Use ${item.name}`);
  if (item.custom) {
    fetchNui('useFakeItemMulti', { event: item.event, count: item.count ?? 1 });
  }
};
