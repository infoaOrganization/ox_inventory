import InventoryGrid from './InventoryGrid';
import { useAppSelector } from '../../store';
import { selectRightInventory } from '../../store/inventory';

const RightInventory: React.FC = () => {
  const rightInventory = useAppSelector(selectRightInventory);

  return <InventoryGrid inventory={rightInventory} isDrop={rightInventory.label == null || (rightInventory.label.startsWith('Drop') || rightInventory.label.trim() == '')} labelPrefix={'(외부) '} />;
};

export default RightInventory;
