from mmdet.apis import init_detector, inference_detector, show_result_pyplot

# 首先下载模型文件https://s3.ap-northeast-2.amazonaws.com/open-mmlab/mmdetection/models/faster_rcnn_r50_fpn_1x_20181010-3d1b3351.pth
# config_file = 'configs/faster_rcnn/faster_rcnn_r50_fpn_1x_coco.py'
# checkpoint_file = 'checkpoints/faster_rcnn_r50_fpn_1x_coco_20200130-047c8118.pth'

config_file = 'xianjin/mask_rcnn_r101_fpn_2x_coco.py'
checkpoint_file = 'xianjin/epoch_24.pth'

# 初始化模型
# device='cuda:0'
model = init_detector(config_file, checkpoint_file, device='cpu')

# 测试一张图片
img = 'ImageData/val01.png'

result = inference_detector(model, img)

show_result_pyplot(model, img, result)
