//
//  CollectionFlowLayout.swift
//  Pods
//
//  Created by xperi on 2016. 10. 5..
//
//
import UIKit

enum ScrollDirection {
    case none
    case right
    case left

    static func direction(_ origin: CGFloat, moved: CGFloat) -> ScrollDirection {
        if origin > 0 {
            if origin > moved {
                return .left
            } else if origin < moved {
                return .right
            }
        }
        return .none
    }
}
///  가운데와 가장 가까운 후보셀을 정해 그 셀로 이동
///  맨 왼쪽과 오른쪽은 예외처리
class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        if let cv = self.collectionView {
            let contentWidth = cv.contentSize.width
            let contentOffset = cv.contentOffset
            let scrollDirection = ScrollDirection.direction(contentOffset.x, moved: proposedContentOffset.x)
            let cvBounds = cv.bounds
            let fullWidth = cvBounds.size.width
            let halfWidth = fullWidth * 0.5
            // 예상 스크롤 정지점을 컬렉션뷰 가운데로 정의
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth

            // 현재 보여지는 셀들
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                // 후보셀
                var candidateAttributes: UICollectionViewLayoutAttributes?

                // 후보셀 리스트
                var candidateAttributesList = [UICollectionViewLayoutAttributes]()

                // 현재 보여지는 셀들 중 후보셀 찾기
                for attributes in attributesForVisibleCells {
                    // 셀타입이 아닐때 처리 (footer , header 등)
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    // 해당 후보셀의 센터 좌표
                    let attributesCenterX  = attributes.center.x
                    // 스크롤 방향을 통해 후보리스트에 넣을건지 결정
                    if scrollDirection == .left {
                        //왼쪽으로 스크롤시에는 후보셀이 컬렉션뷰 가운데 보다 왼쪽에 있을때 후보리스트 등록
                        if attributesCenterX < contentOffset.x + halfWidth {
                            candidateAttributesList.append(attributes)
                        }
                    } else if scrollDirection == .right {
                        //오른쪽으로 스크롤시에는 후보셀이 컬렉션뷰 가운데 보다 오른쪽에 있을때 후보리스트 등록
                        if attributesCenterX > contentOffset.x + halfWidth {
                            candidateAttributesList.append(attributes)
                        }
                    } else {
                        //방향을 알수 없거나(천천히 움직이게 되면) 움직이지 않았을때 후보리스트 등록
                        candidateAttributesList.append(attributes)
                    }
                }
                // 후보셀 리스트 중에 가장 도착점과 차이가 적은 셀을 찾음
                for attributes in candidateAttributesList {
                    if let candAttrs = candidateAttributes {
                        let attributesCenterX  = attributes.center.x
                        let a = attributesCenterX - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes
                        }
                    } else {
                        candidateAttributes = attributes
                    }
                }

                // 찾은 후보셀이 맨 왼쪽 셀이거나 맨 오른쪽 셀인면서 셀좌표가 컬렉션뷰의 반을 넘지 않는지 확인
                if let candidateAttributes = candidateAttributes {
                    let candidateAttributesCenterX = candidateAttributes.center.x
                    // 스크롤이 왼쪽 끝을 넘어 섰으면 제일 앞으로 스크롤
                    if cvBounds.origin.x <= 0 {
                        return CGPoint(x : 0, y : proposedContentOffset.y)
                        // 스크롤이 오른쪽 끝을 넘어 섰으면 제일 끝으로 스크롤
                    } else if cvBounds.origin.x + fullWidth >= contentWidth {
                        return CGPoint(x : contentWidth - fullWidth, y : proposedContentOffset.y)
                    }
                    //위의 예외에 걸리지 않으면 후보셀 위치로 이동
                    return CGPoint(x : candidateAttributesCenterX - halfWidth, y : proposedContentOffset.y)
                }

            }

        }
        // 후보셀을 찾지 못하면 예상 도착지점으로 스크롤
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}
