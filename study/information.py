from mmdet.apis import init_detector, inference_detector, show_result_pyplot
import mmcv
import numpy as np
import glob
import os

config_file = 'configs/faster_rcnn/faster_rcnn_r101_fpn_2x_coco.py'
checkpoint_file = 'checkpoints/faster_rcnn_r101_fpn_2x_coco_20200504.pth'
score_thr = 0.9

# 通过配置文件（config file）和模型文件（checkpoint file）构建检测模型
# device='cuda:0'
model = init_detector(config_file, checkpoint_file, device='cpu')

# 测试多张图片
imgs = glob.glob('ImageData/*.png')

for i, result in enumerate(inference_detector(model, imgs)):
    show_result_pyplot(model, imgs[i], result)

    # 输出图片的猫和狗的数量
    img = mmcv.imread(imgs[i])
    img = img.copy()
    bbox_result = result
    bboxes = np.vstack(bbox_result)
    labels = [
        np.full(bbox.shape[0], i, dtype=np.int32)
        for i, bbox in enumerate(bbox_result)
    ]
    labels = np.concatenate(labels)

    # 根据阈值调整输出的 bboxes 和 labels
    scores = bboxes[:, -1]
    inds = scores > score_thr
    bboxes = bboxes[inds, :]
    labels = labels[inds]

    class_names = model.CLASSES
    cat_dog_dict = {}
    for label in labels:
        cat_dog_dict[class_names[label]] = cat_dog_dict.get(class_names[label], 0) + 1
    for k, v in cat_dog_dict.items():
        print('{0} 有 {1} 只 {2}'.format(imgs[i].split('/')[-1], v, k))
    print('--------------------')
