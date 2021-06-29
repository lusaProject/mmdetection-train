from mmdet.apis import init_detector, inference_detector, show_result_pyplot

import datetime
import time

# config_file = 'configs/faster_rcnn/faster_rcnn_r101_fpn_2x_coco.py'
# checkpoint_file = 'checkpoints/faster_rcnn_r101_fpn_2x_coco_20200504.pth'

config_file = 'xianjin/faster_rcnn_r101_fpn_2x_coco.py'
checkpoint_file = 'xianjin/epoch_48_all.pth'

# 初始化模型
# device='cuda:0'
model = init_detector(config_file, checkpoint_file, device='cpu')

# 测试一张图片
img = 'ImageData/test02.png'

begin = datetime.datetime.now()
result = inference_detector(model, img)
end = datetime.datetime.now()
print(end-begin)
show_result_pyplot(model, img, result)
