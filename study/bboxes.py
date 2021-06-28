import numpy as np
from mmdet.apis import init_detector, inference_detector
import mmcv
import cv2

threshold = 0.9  # confidence score
# config_file = 'configs/faster_rcnn/faster_rcnn_r101_fpn_2x_coco.py'
# checkpoint_file = 'checkpoints/faster_rcnn_r101_fpn_2x_coco_20200504.pth'

config_file = 'xianjin/mask_rcnn_r101_fpn_2x_coco.py'
checkpoint_file = 'xianjin/epoch_24.pth'

# 通过配置文件（config file）和模型文件（checkpoint file）构建检测模型
# device='cuda:0'
model = init_detector(config_file, checkpoint_file, device='cpu')
# 测试单张图片并展示结果
img_path = 'ImageData/val01.png'
result = inference_detector(model, img_path)
bboxes = np.vstack(result)
labels = [
    np.full(bbox.shape[0], i, dtype=np.int32)
    for i, bbox in enumerate(result)
]
labels = np.concatenate(labels)
img = cv2.imread(img_path)
scores = bboxes[:, -1]
inds = scores > threshold
bboxes = bboxes[inds, :]
labels = labels[inds]
class_names = model.CLASSES
cat_dog_dict = {}
for label in labels:
    cat_dog_dict[class_names[label]] = cat_dog_dict.get(class_names[label], 0) + 1
print('cat_dog_dict ', cat_dog_dict)
for k, v in cat_dog_dict.items():
    print('{0} 有 {1} 只 {2}'.format(img_path, v, k))
for bbox in bboxes:
    left_top = (bbox[0], bbox[1])
    right_bottom = (bbox[2], bbox[3])
    print(left_top)
    print(right_bottom)
    color = (0, 255, 0)
    cv2.rectangle(img, (22, 15), (372, 385), color, 2)
     # cv2.rectangle(img, left_top, right_bottom, color, 2)
# cv2.imwrite('res_cat.12176.jpg', img)
