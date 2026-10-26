# 0026_arrays_basic
# NOTE: Python list is a dynamic array; use array module for packed typed arrays.

from array import array

nums = [1, 2, 3]
nums.append(4)
print(nums, nums[0], nums[-1], len(nums))
print(array("i", [1, 2, 3]))
