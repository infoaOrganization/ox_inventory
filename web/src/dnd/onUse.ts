//import toast from "react-hot-toast";
import { fetchNui } from '../utils/fetchNui';
import { Slot } from '../typings';

export const onUse = (item: Slot) => {
  //toast.success(`Use ${item.name}`);
  if (item.custom) {
    fetchNui('useFakeItem', item.event);
  } else {
    fetchNui('useItem', item.slot);
  }
};
